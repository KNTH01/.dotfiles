#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

chezmoi -S "$repo" apply -D "$tmpdir" --force

test -f "$tmpdir/.config/fish/config.fish"
test -f "$tmpdir/.config/fish/fish_plugins"
test ! -e "$tmpdir/.config/fish/fish_variables"
test ! -e "$tmpdir/.config/fish/completions/deno.fish"
test ! -e "$tmpdir/.config/fish/completions/mise.fish"
! rg -n '/home/knth/.dotfiles/bin' "$tmpdir/.config/fish"
env HOME="$tmpdir" XDG_CONFIG_HOME="$tmpdir/.config" PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin" fish -i -c exit >/dev/null 2>"$tmpdir/fish.stderr"
test ! -s "$tmpdir/fish.stderr"
