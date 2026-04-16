# dotfiles

Phase 1 CLI dotfiles in this repo are managed with chezmoi.

## Bootstrap

```bash
git clone git@github.com:KNTH01/.dotfiles.git ~/.dotfiles
chezmoi init --source="$HOME/.dotfiles"
chezmoi apply
```

If this machine needs encrypted files, configure your age identity in `~/.config/chezmoi/chezmoi.toml` before running `chezmoi apply`.

## Managed in phase 1

- `~/.gitconfig`
- `~/.gitconfig.user` (encrypted)
- `~/.tmux.conf`
- `~/.config/mise/config.toml`
- `~/.config/fish/...`
- `~/.local/bin/cheat`
- `~/.local/bin/omarchy-webapp-install` (desktop hosts only)

## Fish generated completions

`deno.fish` and `mise.fish` are generated locally and are not tracked in Git.
After `chezmoi apply` on a machine with `deno` and `mise` installed, run:

```bash
~/.local/bin/fish-regenerate-completions
```

This writes:
- `~/.config/fish/completions/deno.fish`
- `~/.config/fish/completions/mise.fish`

## Legacy workflow

`install.sh` is retired for migrated phase 1 paths.
Do not use broad Stow commands for files already managed by chezmoi.
