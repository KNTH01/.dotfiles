# Chezmoi Phase 1 Status and Next Steps

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Capture the actual state of the current phase 1 chezmoi PR and make the next session resume cleanly without rediscovering what landed and what remains.

**Architecture:** This is a handoff/status plan, not the original migration design. It records the branch's real outcomes, the deliberate deviations from the original execution plan, the validation already completed on `velvet`, and the recommended order for the remaining post-PR work.

**Tech Stack:** chezmoi, age, Fish, tmux, mise, Git, Markdown docs

---

## Current PR snapshot

- Branch: `feat/chezmoi-migration-phase1`
- PR: `https://github.com/KNTH01/.dotfiles/pull/1`
- Latest branch commit at time of writing: `adf4b25 refactor: drop unnecessary fish template suffixes`

## What actually landed in the current PR

### Core chezmoi scaffolding

- `.chezmoiroot`
- `chezmoi/age/recipients.txt`
- `home/.chezmoidata/machines.yaml`
- local-only chezmoi config at `~/.config/chezmoi/chezmoi.toml`

### Git and secrets

- `home/dot_gitconfig`
- `home/encrypted_dot_gitconfig.user.age`
- Git history preserved from `gitconfig/.gitconfig` to `home/dot_gitconfig`
- live `~/.gitconfig` is now a normal chezmoi-managed file, not the old symlink

### tmux

- `home/dot_tmux.conf`

### mise

- `home/dot_config/mise/config.toml`

### Fish

- `home/dot_config/fish/config.fish`
- split `conf.d/` layout under `home/dot_config/fish/conf.d/`
- split `functions/` layout under `home/dot_config/fish/functions/`
- generated completions removed from source-of-truth
- helper added for local regeneration:
  - `home/dot_local/bin/executable_fish-regenerate-completions`
- only these Fish files still need chezmoi templates:
  - `home/dot_config/fish/functions/web2app.fish.tmpl`
  - `home/dot_config/fish/functions/web2app-remove.fish.tmpl`
- these files are now plain `.fish` because they do not contain real chezmoi template logic:
  - `home/dot_config/fish/conf.d/00-core-paths.fish`
  - `home/dot_config/fish/conf.d/10-optional-tools.fish`
  - `home/dot_config/fish/conf.d/20-prompt.fish`
  - `home/dot_config/fish/conf.d/40-deno.fish`
  - `home/dot_config/fish/conf.d/50-arch-maintenance.fish`
  - `home/dot_config/fish/functions/fish_greeting.fish`

### CLI-safe scripts and docs

- `bin/cheat` moved with history preserved to:
  - `home/dot_local/bin/executable_cheat`
- `bin/omarchy-webapp-install` intentionally remains deferred
- `README.md` now documents a chezmoi-first workflow
- `install.sh` is retired for migrated phase 1 paths

## Important differences from the original implementation plan

- The branch ended with **manual validation**, not repo-tracked `tests/chezmoi/*` scripts.
- Checked-in validation scripts were created during execution, then removed from the PR after review.
- The actual encrypted Git secret path is `home/encrypted_dot_gitconfig.user.age`.
- The actual CLI script path is `home/dot_local/bin/executable_cheat`.
- Fish completions are regenerated locally via `~/.local/bin/fish-regenerate-completions` instead of being tracked in Git.
- Several Fish files originally planned as `.tmpl` were renamed to plain `.fish` because they do not use chezmoi templating.
- The extra age recipient added during validation is now considered permanent and remains in `chezmoi/age/recipients.txt`.

## Validation already completed on `velvet`

The current branch has already been manually smoke-tested on `velvet` with these outcomes:

- `chezmoi status` -> clean after apply
- `chezmoi diff` -> clean after apply
- `fish -i -c exit` -> passes
- `~/.local/bin/fish-regenerate-completions` -> regenerates `deno.fish` and `mise.fish`
- `tmux -L chezmoi-validate -f ~/.tmux.conf start-server \; kill-server` -> passes
- `git config --show-origin --get include.path` -> includes `~/.gitconfig.user`
- `git config --show-origin --get user.name` -> passes
- `git config --show-origin --get user.email` -> passes
- `command -v cheat` -> resolves to `~/.local/bin/cheat`
- `cheat ls` -> returns data from `cheat.sh`

## Not yet done

- Live validation/apply on `pixelpirate`
- Retirement of stale default chezmoi source dir `~/.local/share/chezmoi` if it is still present and unused
- Phase 2 design + implementation plan for the next deferred slice

## Recommended next session order

### Task 1: Finish the phase 1 PR

If PR `#1` is still open, do a final review and merge it. If it is already merged, skip to Task 2.

### Task 2: Validate and apply on `pixelpirate`

On `pixelpirate`, confirm chezmoi is pointed at the repo and then run:

```bash
chezmoi source-path ~/.gitconfig
chezmoi status
chezmoi diff
chezmoi apply --dry-run
chezmoi apply
fish -i -c exit
tmux -L chezmoi-validate -f ~/.tmux.conf start-server \; kill-server
git config --show-origin --get include.path
git config --show-origin --get user.name
git config --show-origin --get user.email
command -v cheat
```

If `deno` and `mise` exist there, also run:

```bash
~/.local/bin/fish-regenerate-completions
```

### Task 3: Retire stale default chezmoi source state if it is unused

After confirming `sourceDir = "/home/knth/.dotfiles"` is the only active source, inspect `~/.local/share/chezmoi`. If it is stale, retire or remove it so there is only one source of truth.

### Task 4: Plan phase 2 before implementing anything

Do not jump straight into the next migration slice. Write a fresh design/implementation plan first.

Recommended constraint for phase 2:

- pick **one** deferred slice only
- do **not** mix `nvim` and desktop/UI migration in the same first follow-up branch

Candidate phase 2 slices:

1. `nvim` as its own dedicated migration
2. desktop/UI configs plus deferred helper scripts such as `bin/omarchy-webapp-install`

The first concrete thing to do tomorrow, if phase 1 is merged, is **Task 2: validate and apply on `pixelpirate`**.
