#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:KNTH01/.dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"
CHEZMOI_CONFIG="$CHEZMOI_CONFIG_DIR/chezmoi.toml"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_deps_arch() {
  sudo pacman -S --needed git chezmoi
}

install_deps_debian() {
  sudo apt update
  sudo apt install -y git chezmoi
}

echo "==> Checking dependencies"

if ! need_cmd git || ! need_cmd chezmoi; then
  if need_cmd pacman; then
    install_deps_arch
  elif need_cmd apt; then
    install_deps_debian
  else
    echo "Unsupported distro. Install git and chezmoi manually, then rerun."
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

mkdir -p "$CHEZMOI_CONFIG_DIR"

cat > "$CHEZMOI_CONFIG" <<EOF
sourceDir = "$DOTFILES_DIR"
EOF

echo "==> Wrote $CHEZMOI_CONFIG"

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
