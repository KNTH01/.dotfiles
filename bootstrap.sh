#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:KNTH01/.dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"
CHEZMOI_CONFIG="$CHEZMOI_CONFIG_DIR/chezmoi.toml"

AGE_DIR="$HOME/.config/age"
AGE_KEY="$AGE_DIR/key-chezmoi.txt"
AGE_RECIPIENTS="$DOTFILES_DIR/chezmoi/age/recipients.txt"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_deps_arch() {
  sudo pacman -S --needed git chezmoi age
}

install_deps_debian() {
  sudo apt update
  sudo apt install -y git chezmoi age
}

echo "==> Checking dependencies"

if ! need_cmd git || ! need_cmd chezmoi || ! need_cmd age; then
  if need_cmd pacman; then
    install_deps_arch
  elif need_cmd apt; then
    install_deps_debian
  else
    echo "Unsupported distro. Install git, chezmoi, and age manually, then rerun."
    exit 1
  fi
fi

echo "==> Cloning/updating dotfiles"

if [ ! -d "$DOTFILES_DIR/.git" ]; then
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  git -C "$DOTFILES_DIR" pull --ff-only
fi

echo "==> Writing chezmoi config"

mkdir -p "$CHEZMOI_CONFIG_DIR" "$AGE_DIR"
chmod 700 "$AGE_DIR"

cat > "$CHEZMOI_CONFIG" <<EOF
sourceDir = "$DOTFILES_DIR"
encryption = "age"

[age]
    identities = ["$AGE_KEY"]
    recipientsFile = "$AGE_RECIPIENTS"
EOF

echo "==> Wrote $CHEZMOI_CONFIG"

if [ ! -f "$AGE_KEY" ]; then
  echo "==> Generating age key for this host"
  age-keygen -o "$AGE_KEY"
  chmod 600 "$AGE_KEY"

  NEW_RECIPIENT="$(grep '^# public key:' "$AGE_KEY" | sed 's/^# public key: //')"

  echo
  echo "==> New age recipient:"
  echo "    $NEW_RECIPIENT"
  echo
  echo "Add this recipient to:"
  echo "    $AGE_RECIPIENTS"
  echo
  echo "Then re-encrypt chezmoi secrets from an already-authorized machine:"
  echo "    cd ~/.dotfiles"
  echo "    chezmoi re-add"
  echo "    git add chezmoi/age/recipients.txt"
  echo "    git add -u"
  echo "    git commit -m \"chezmoi: add age recipient\""
  echo "    git push"
  echo
  exit 2
fi


chmod 600 "$AGE_KEY"

echo "==> Checking chezmoi"

chezmoi source-path
chezmoi doctor

echo
echo "==> Previewing diff"
chezmoi diff

echo
read -r -p "Apply dotfiles now? [y/N] " answer

case "$answer" in
  y|Y|yes|YES)
    chezmoi apply
    ;;
  *)
    echo "Skipped apply. Run manually with:"
    echo "  chezmoi apply"
    ;;
esac
