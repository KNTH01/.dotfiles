# dotfiles

dotfiles in this repo are managed with chezmoi.

## Bootstrap

```bash
git clone git@github.com:KNTH01/.dotfiles.git ~/.dotfiles
~/.dotfiles/bootstrap.sh
```

Or manually:

```bash
chezmoi init --source="$HOME/.dotfiles"
chezmoi apply
```

## Managed in phase 1

- `~/.gitconfig`
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
