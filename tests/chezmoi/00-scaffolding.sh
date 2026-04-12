#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles

[[ "$(tr -d '\n' < "$repo/.chezmoiroot" 2>/dev/null)" == "home" ]]
[[ -f "$repo/home/.chezmoidata/machines.yaml" ]]
chezmoi -S "$repo" data --format=yaml | rg '^machines:'
[[ "$(chezmoi source-path)" == "$repo/home" ]]
