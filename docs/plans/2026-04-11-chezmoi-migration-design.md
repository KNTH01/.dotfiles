# Chezmoi Migration Design

## Goal

Migrate the current gnustow-managed dotfiles repo to **chezmoi** with a single shared source state, machine-based overrides, and age-encrypted secrets.

The end state should:

- keep the current userland experience working on **velvet** and **pixelpirate**
- make it easy to add a future laptop that mostly inherits velvet
- keep the repo readable and low-duplication
- avoid bootstrapping package installs or system setup in this phase

## Context

Today the repo is organized around stow-style folders per app. That works, but it makes cross-machine management awkward and encourages path-heavy configs.

The important real-world constraint is that **pixelpirate is a Debian server, but it still uses the same desktop/userland configs when SSHing in**. So the design is not really “desktop vs server”. It is:

- mostly shared config
- a few machine-specific overrides
- very limited OS-specific branching only when truly necessary

The current known machines are:

- **velvet** — current Arch Linux machine
- **pixelpirate** — Debian server
- **future laptop** — expected to be Arch or CachyOS, and should mostly inherit velvet

## Non-goals

This migration does **not** try to solve everything at once.

Out of scope for this phase:

- package installation / bootstrap automation
- full system provisioning
- `/etc` management like `pacman.conf`
- replacing chezmoi itself with config management for this repo
- a large refactor of app configs unless needed for portability

## Proposed Architecture

### Repo layout

The repo root stays the repo root, but the actual chezmoi source state lives under `home/`. The git repository itself can still be named `.dotfiles`; chezmoi only cares about the source root.

A `.chezmoiroot` file at the repo root will point chezmoi at that subdirectory:

```text
home
```

That means the repo can keep non-source-state files at the top level, while chezmoi reads only from `home/`.

Suggested layout:

```text
repo/
  .chezmoiroot
  README.md
  docs/
    plans/
  home/
    dot_zshrc.tmpl
    dot_tmux.conf
    dot_gitconfig
    encrypted_private_dot_gitconfig.user
    dot_local/
      bin/
    dot_config/
      fish/
      nvim/
      bat/
      gitui/
      wezterm/
      alacritty/
      rofi/
      polybar/
      lvim/
      awesome/
    dot_zsh/
      arco.zsh
      me.aliases
      arcolinux.aliases
    dot_xmonad/
      scripts/
      xmonad.hs
```

### Machine model

The primary axis is **hostname**, not OS.

- `pixelpirate` gets explicit hostname-based overrides where needed
- `velvet` and the future laptop share the common/default behavior
- OS-specific branching is allowed only as a fallback for truly platform-dependent bits

The key principle is that **95% of the config should stay common**. Host-specific logic should be narrow and local.

### Template strategy

Files that need portable paths, host-specific behavior, or optional command checks become `.tmpl` files.

Use templates for:

- hardcoded paths like `/home/knth/...`
- hostname branches
- optional integrations that may not exist on every machine
- small per-machine variations in shell/editor setup

Prefer simple checks in templates or shell snippets, such as:

- `{{ if eq .chezmoi.hostname "pixelpirate" }}` for real machine-specific differences
- `type -q`, `command -v`, or `lookPath` for optional executables
- `{{ .chezmoi.homeDir }}` instead of hardcoded home paths

The goal is to keep common files readable and avoid turning the repo into a maze of machine profiles.

## File Mapping Strategy

The existing stow folders map cleanly to chezmoi source-state names.

### Examples

| Current path | Chezmoi source-state path |
| --- | --- |
| `zsh/.zshrc` | `home/dot_zshrc.tmpl` |
| `zsh/arco.zsh` | `home/dot_zsh/arco.zsh` |
| `zsh/.zsh/me.aliases` | `home/dot_zsh/me.aliases` |
| `zsh/.zsh/arcolinux.aliases` | `home/dot_zsh/arcolinux.aliases` |
| `fish/.config/fish/config.fish` | `home/dot_config/fish/config.fish.tmpl` |
| `gitconfig/.gitconfig` | `home/dot_gitconfig` |
| `gitconfig/.gitconfig.user` | `home/encrypted_private_dot_gitconfig.user` |
| `tmux/.tmux.conf` | `home/dot_tmux.conf` |
| `nvim/.config/nvim/...` | `home/dot_config/nvim/...` |
| `bin/*` | `home/executable_dot_local/bin/*` |
| `vivaldi/customcss/custom.css` | `home/dot_config/vivaldi/customcss/custom.css` or a similar portable target, depending on how it is consumed |

### Rules of thumb

- hidden files in `$HOME` use `dot_`
- hidden directories use `dot_` on the directory name
- executable helper scripts use `executable_` when they should land as executable
- secrets use `encrypted_` and usually `private_` too
- templates use `.tmpl`

### Current repo folders likely to migrate

These are the main userland areas worth moving into chezmoi:

- shell: `zsh/`, `fish/`, `tmux/`
- editor: `nvim/`, `lvim/`
- git: `gitconfig/`, `gitui/`
- terminal/UI: `wezterm/`, `alacritty/`, `bat/`, `rofi/`, `polybar/`
- desktop/windowing: `awesome/`, `xmonad/`
- scripts/helpers: `bin/`
- small app-specific config: `vivaldi/`

`pacman/etc/pacman.conf` is intentionally left out of the first pass because it is system-level and not part of the common userland migration.

## Secrets and Encryption

Secrets will be stored encrypted in the chezmoi source state using **age**.

Design choices:

- use `age` rather than `gpg`
- keep one identity per machine
- allow multiple recipients per encrypted file so the same secret can be shared across several authorized devices
- keep the age identities on each machine, not in the repo

The sensitive file currently called out is:

- `~/.gitconfig.user`

That becomes an encrypted private chezmoi file. Additional secrets can follow the same pattern later.

When a new machine is added, the workflow should be:

1. generate an age identity for the new machine
2. add its public recipient to the relevant encrypted files
3. re-encrypt so the new device can decrypt them

## Runtime Flow

The apply flow should stay simple:

1. chezmoi reads the source state from `home/` via `.chezmoiroot`
2. templates render using the local machine hostname and environment
3. encrypted files decrypt only on authorized machines
4. chezmoi writes the rendered files into `$HOME`
5. `chezmoi diff` and `chezmoi apply` make changes visible before they land

This keeps the config deterministic and easy to reason about across machines.

## Validation Strategy

The migration is successful only if the following are true:

- `chezmoi diff` is clean or explains expected differences
- `chezmoi apply --dry-run` succeeds on both velvet and pixelpirate
- common shell/editor configs still work on both machines
- optional integrations do not error out when a command is missing
- encrypted files decrypt on authorized machines
- the future laptop can be added by reusing the velvet behavior with minimal extra branching

Manual smoke tests after apply should include:

- shell startup (`zsh` and `fish`)
- `tmux` config load
- `nvim` launch
- `git` reading the private include file
- a quick SSH session on pixelpirate to verify the common userland config behaves correctly

## Risks and Mitigations

### Risk: host-specific logic spreads everywhere

Mitigation:

- keep the common path as the default
- only branch on hostname for true exceptions
- prefer local template checks over global profile systems

### Risk: hardcoded paths break on a new machine

Mitigation:

- replace absolute paths with `{{ .chezmoi.homeDir }}` or relative paths
- avoid embedding `/home/knth` directly in migrated files

### Risk: optional tools are missing on pixelpirate

Mitigation:

- guard integrations with `type -q`, `command -v`, or `lookPath`
- keep the Debian server on the same userland configs, but don’t assume desktop-only tools are present

### Risk: secrets cannot be decrypted on a new device

Mitigation:

- treat age recipient addition as part of the onboarding checklist for every new machine
- verify decryption before applying the rest of the source state

## Rollout Plan at a High Level

This design is intended to be migrated in small slices:

1. introduce `.chezmoiroot` and the `home/` source root
2. move the most central shell and git files first
3. migrate editor and terminal configs
4. add age-encrypted secrets
5. verify velvet and pixelpirate independently
6. defer `/etc` and other system-level config to a follow-up phase

## Summary

The migration should keep the repo simple:

- one shared chezmoi source state under `home/`
- hostname-based machine differences
- age-encrypted secrets
- no bootstrap or system provisioning in phase 1
- userland configs that work on both velvet and pixelpirate, with the future laptop inheriting velvet by default
