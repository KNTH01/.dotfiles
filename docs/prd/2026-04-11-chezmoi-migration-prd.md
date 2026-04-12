# Chezmoi Dotfiles Migration PRD

## Problem Statement

I currently manage my dotfiles with a GNU Stow-style layout. It works on one machine, but it is awkward to maintain across multiple machines with different roles and different optional tooling.

My current machines are:

- **velvet** — current Arch Linux host
- **pixelpirate** — Debian server and SSH target
- **future laptop** — expected to be Arch or CachyOS and should mostly behave like `velvet`

The main pain points are:

- the current Stow structure is not ideal for machine-specific differences
- some configs assume optional tools are installed everywhere
- some configs still contain hardcoded paths that should become more portable
- secrets are not yet managed in a safe, portable, encrypted workflow
- I want my core CLI userland to feel the same when I SSH into `pixelpirate`
- I want to add a future laptop without redesigning the repo again
- I do not want this to turn into a full bootstrap or system provisioning project

## Solution

Move the repo to **chezmoi** as the source of truth for dotfiles.

The migration should:

- keep a **single repo** as the source of truth
- keep the git repo rooted at `.dotfiles`
- keep the actual chezmoi source state under `home/` via `.chezmoiroot`
- keep documentation and planning notes outside the managed home-state tree
- prefer one shared config base, with machine-specific behavior kept narrow and obvious
- prefer optional-tool checks and portable paths before hostname-specific branching
- use **age** for encrypted secrets
- reuse the existing local age identity on each machine
- keep public age recipients in the repo and private identities outside the repo
- keep phase 1 focused on the **core CLI/userland migration**

### Phase 1 scope

Phase 1 should migrate only the core, lower-risk slice:

- chezmoi scaffolding
- `git`
- encrypted `~/.gitconfig.user`
- `tmux`
- `mise`
- `fish`
- CLI-safe helper scripts that should live in `~/.local/bin`

Phase 1 should explicitly defer:

- `nvim`
- desktop/UI configs
- `zsh`
- `/etc` and other system-level files
- package installation / bootstrap automation

## User Stories

1. As the dotfiles owner, I want one source of truth for my configs, so that I can update settings once and apply them everywhere.
2. As the dotfiles owner, I want my current `velvet` workflow to keep working during the migration, so that I do not break my daily machine.
3. As the dotfiles owner, I want `pixelpirate` to receive the same core CLI/userland config, so that SSH sessions feel familiar.
4. As the dotfiles owner, I want `pixelpirate` to avoid desktop/UI-only payload, so that the server only gets what it actually needs.
5. As the dotfiles owner, I want a future laptop to be onboarded by adding one machine entry and one age recipient, so that new-machine setup stays simple.
6. As the dotfiles owner, I want unknown hosts to fail closed by default, so that chezmoi does not accidentally apply desktop-oriented behavior to an unclassified machine.
7. As the dotfiles owner, I want host-specific behavior to be localized and rare, so that the repo stays readable.
8. As the dotfiles owner, I want portable paths and optional-tool checks, so that shared configs work across Arch and Debian.
9. As the dotfiles owner, I want my `fish` config to remain usable across machines, so that shell startup does not break when tools are missing.
10. As the dotfiles owner, I want my `tmux` config to remain available, so that terminal workflows stay consistent.
11. As the dotfiles owner, I want my `git` config to preserve my aliases and private identity settings, so that my Git workflow does not change.
12. As the dotfiles owner, I want `mise` config tracked in dotfiles, so that my tool manifest is explicit and portable.
13. As the dotfiles owner, I want helper scripts to live in `~/.local/bin`, so that they use a standard executable location.
14. As the dotfiles owner, I want secrets encrypted in the repo, so that I can sync them safely across authorized machines.
15. As the dotfiles owner, I want each machine to keep its private age identity locally, so that compromising one machine does not require sharing a common private key everywhere.
16. As the dotfiles owner, I want the public age recipient list versioned in Git, so that adding a new machine is explicit and reviewable.
17. As the dotfiles owner, I want generated and machine-local shell artifacts to be rebuildable instead of versioned, so that the repo only tracks intentional source config.
18. As the dotfiles owner, I want to preview and dry-run changes before applying them, so that I can migrate incrementally and safely.
19. As the dotfiles owner, I want a small checked-in validation script/checklist, so that the migration can be re-verified on both hosts.
20. As the dotfiles owner, I want broad Stow install instructions retired once chezmoi owns the migrated slice, so that I do not accidentally let two tools manage the same target path.

## Implementation Decisions

- Use **chezmoi** as the dotfiles manager instead of GNU Stow.
- Keep **`/home/knth/.dotfiles`** as the only real Git source repo.
- Configure local chezmoi to use that repo as `sourceDir`.
- Use `.chezmoiroot` so the source state lives under `home/` and the repo root can still hold docs and migration assets.
- Keep machine metadata minimal and repo-tracked in `home/.chezmoidata/machines.yaml`.
- Use a **common-first** model:
  - prefer portable paths and optional-tool checks first
  - use hostname branches only for real exceptions
- Treat `pixelpirate` as a **non-desktop** machine.
- Treat unknown hosts as **fail closed** until explicitly added to machine data.
- Keep phase 1 limited to `git`, encrypted Git identity, `tmux`, `mise`, `fish`, and CLI-safe scripts.
- Defer `nvim` because the source-first chezmoi workflow is more disruptive there and is better handled after the core migration is stable.
- Keep `zsh` out of scope for now because it is no longer part of the active workflow.
- Move migrated CLI-safe scripts to `~/.local/bin`.
- Manage only **hand-written source config** in chezmoi.
- Exclude generated or machine-local artifacts such as Fisher vendor state, `fish_variables`, and generated completions.
- Do not auto-run Fisher bootstrap or `mise install` during `chezmoi apply`.
- Start encrypted secret migration with **only** `~/.gitconfig.user`.
- Reuse the existing local age identity at `/home/knth/.config/gopass/age/identities`.
- Keep the canonical public recipient list in the repo, but keep private identities outside the repo.
- Retire the broad Stow installer/docs as the primary workflow once phase 1 lands.
- Do not add a separate backup workflow beyond Git for tracked files; only cut over files once the desired state is committed.

## Testing Decisions

A good test for this migration validates **rendered behavior and safe cutover**, not internal template cleverness.

The most important checks are:

- `chezmoi diff` shows only expected changes
- `chezmoi apply --dry-run` succeeds on `velvet` and `pixelpirate`
- the rendered `fish` config starts cleanly even when optional tools are absent
- `git` still reads the encrypted private include file on authorized machines
- `tmux` loads cleanly from the rendered file
- `mise` renders the expected tracked tool manifest
- migrated scripts land in `~/.local/bin`
- unknown hosts do not implicitly get desktop behavior
- Fish generated artifacts are rebuildable and no longer treated as source-of-truth files

Validation should include both:

- a small checked-in validation script suite
- a manual smoke-test checklist for live `velvet` and `pixelpirate`

## Out of Scope

- package installation or full bootstrap automation
- system provisioning
- `/etc` management during the first migration pass
- distro-specific package management workflows beyond optional-tool tolerance in config
- `nvim` migration in phase 1
- desktop/UI config migration in phase 1
- `zsh` migration in phase 1
- a full secret sweep beyond `~/.gitconfig.user`
- tracking generated shell completions or other generated shell state as source-of-truth
- a broad configuration spring-cleaning unrelated to portability/readability of touched files

## Further Notes

- `pixelpirate` still matters as a day-to-day SSH environment, but it should receive the **core CLI/userland** slice, not the whole desktop stack.
- The future laptop should mostly inherit the shared/default desktop behavior, but it must be explicitly added to machine data before apply.
- The first migration should optimize for safety, clarity, and reversible incremental rollout.
- Once phase 1 is stable, follow-up work can migrate `nvim`, desktop/UI configs, and other remaining userland slices.