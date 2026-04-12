#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

chezmoi -S "$repo" apply -D "$tmpdir" --force

test -f "$tmpdir/.config/mise/config.toml"
rg '^chezmoi = "latest"$' "$tmpdir/.config/mise/config.toml"
rg '^"npm:@ccusage/opencode" = "latest"$' "$tmpdir/.config/mise/config.toml"
