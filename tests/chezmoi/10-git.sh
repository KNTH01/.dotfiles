#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

chezmoi -S "$repo" apply -D "$tmpdir" --force

test -f "$tmpdir/.gitconfig"
test -f "$tmpdir/.gitconfig.user"
rg 'path = ~/.gitconfig.user' "$tmpdir/.gitconfig"
[[ "$(git config --file "$tmpdir/.gitconfig" --get include.path)" == '~/.gitconfig.user' ]]
