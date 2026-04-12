# Chezmoi Dotfiles Migration PRD

## Problem Statement

I currently manage my dotfiles with a stow-style layout that works, but it is awkward to maintain across multiple machines. The repo contains a mix of shell configs, editor configs, terminal configs, helper scripts, and secrets, and some files depend on hardcoded paths or manual setup. I want a single, reliable dotfiles system that works on my current Arch machine, `velvet`, my Debian server `pixelpirate`, and a future laptop that should mostly behave like `velvet`.

The main pain points are:

- the current structure is not ideal for machine-specific differences
- some configs contain absolute paths that will break on another device
- secrets are not yet managed in a safe and portable way
- I want my everyday userland config to work the same way when I SSH into `pixelpirate`
- I want to add a future laptop without redesigning the whole repo
- I do not want to turn this into a full system provisioning project

## Solution

Move the repo to **chezmoi** as the source of truth for dotfiles.

The migration should:

- keep one shared config base for almost everything
- use hostname-based overrides only for the few cases that differ by machine
- keep `velvet` and the future laptop aligned by default
- allow `pixelpirate` to use the same userland configs for SSH sessions
- encrypt sensitive files with **age** so they can be shared safely across authorized devices
- keep the first phase focused on userland dotfiles only, not package installation or `/etc`

The repo should remain easy to read:

- the repo root should hold documentation and planning notes
- the actual chezmoi source state should live under `home/`
- the source root should be selected with `.chezmoiroot`
- machine-specific behavior should stay localized and rare

## User Stories

1. As the dotfiles owner, I want one source of truth for my configs, so that I can update settings once and apply them everywhere.
2. As the dotfiles owner, I want my current `velvet` setup to keep working after the migration, so that I do not lose my daily workflow.
3. As the dotfiles owner, I want `pixelpirate` to use the same shell and editor configs over SSH, so that remote sessions feel familiar.
4. As the dotfiles owner, I want a future laptop to inherit the `velvet` behavior by default, so that onboarding a new machine is quick.
5. As the dotfiles owner, I want to branch on hostname for rare exceptions, so that machine-specific differences stay isolated.
6. As the dotfiles owner, I want most configs to be shared across machines, so that I avoid unnecessary duplication.
7. As the dotfiles owner, I want secrets to be encrypted in the repo, so that I can sync them without exposing private data.
8. As the dotfiles owner, I want encrypted secrets to be readable on all authorized devices, so that I do not need separate secret workflows per machine.
9. As the dotfiles owner, I want to add a new device recipient later, so that I can onboard a new laptop without rethinking the secret model.
10. As the dotfiles owner, I want config files to use portable paths, so that the same files work on different machines.
11. As the dotfiles owner, I want to remove hardcoded home-directory paths, so that the repo is not tied to one username or one device.
12. As the dotfiles owner, I want shell configs to load optional tooling only when it exists, so that the same config works on minimal systems too.
13. As the dotfiles owner, I want my `zsh` setup to remain usable, so that my interactive shell behaves the way I expect.
14. As the dotfiles owner, I want my `fish` setup to remain usable, so that my alternative shell still works across machines.
15. As the dotfiles owner, I want my `tmux` configuration to remain available, so that terminal workflows stay consistent.
16. As the dotfiles owner, I want my `nvim` configuration to remain portable, so that my editor works the same on every machine.
17. As the dotfiles owner, I want my `git` configuration to keep my aliases and identity settings, so that my Git workflow does not change.
18. As the dotfiles owner, I want helper scripts to live in a standard binary location, so that they are easy to find and execute.
19. As the dotfiles owner, I want app-specific configs like terminal, launcher, and desktop tooling to stay organized, so that I can update each tool independently.
20. As the dotfiles owner, I want to preview changes before applying them, so that I can avoid breaking a machine by accident.
21. As the dotfiles owner, I want to use dry-run validation during migration, so that I can confirm behavior before committing to a change.
22. As the dotfiles owner, I want documentation and planning notes to stay outside the managed home-state tree, so that the repo stays understandable.
23. As the dotfiles owner, I want to postpone system-level files like `/etc/pacman.conf`, so that the first migration stays focused and low risk.
24. As the dotfiles owner, I want to migrate incrementally, so that I can validate one config area at a time instead of changing everything at once.
25. As the dotfiles owner, I want host-specific behavior to be obvious when I read a file, so that I can debug differences quickly.
26. As the dotfiles owner, I want the future laptop to require minimal additional setup, so that I can add it with very little extra work.
27. As the dotfiles owner, I want the Debian server to tolerate desktop-oriented configs when they are also used during SSH sessions, so that the same config base can serve both contexts.
28. As the dotfiles owner, I want the repo to stay readable for future maintenance, so that I can safely revisit it months later.

## Implementation Decisions

- Use **chezmoi** as the dotfiles manager instead of gnustow/stow.
- Keep a **single repo** with one shared source state.
- Place the source state under `home/` and make it the active root with `.chezmoiroot`.
- Keep the git repository root available for documentation, planning notes, and migration artifacts.
- Use **hostname-based branching** as the primary mechanism for machine-specific behavior.
- Treat `velvet` and the future laptop as the same default machine family unless a file needs a tiny override.
- Allow `pixelpirate` to use the same userland configs rather than creating a separate server-only stack.
- Use templates only where needed for portable paths, host-specific branches, or optional dependencies.
- Replace hardcoded absolute paths with portable expressions or environment-aware logic.
- Use **age** for encrypted files.
- Support multiple recipients per encrypted file so several authorized devices can decrypt the same secret.
- Keep machine identities locally on each device rather than in the repo.
- Keep phase 1 scoped to userland files and defer system-level provisioning, bootstrap automation, and `/etc` management.
- Preserve the current repo name if desired; chezmoi only needs the source root to be correct.
- Keep optional integrations resilient when the relevant command is missing.

## Testing Decisions

A good test for this migration validates **external behavior**, not template internals.

The most important checks are:

- `chezmoi diff` shows only the expected changes
- `chezmoi apply --dry-run` succeeds on each authorized machine
- the rendered shell configs start cleanly in interactive sessions
- the editor config loads cleanly and does not rely on hardcoded local paths
- encrypted secrets decrypt correctly on authorized devices
- a newly added machine can be onboarded by adding a recipient and applying the repo
- optional integrations fail gracefully when a dependency is absent
- machine-specific branches render the right output for the active hostname

Modules or areas that should be validated:

- source-state layout and file mapping
- hostname-based template rendering
- encrypted secret handling
- shell/editor runtime behavior after apply
- migration compatibility for `velvet` and `pixelpirate`

Good prior art for tests in this repo would be the current validation style used for config changes: small, focused checks that exercise the final rendered behavior and not the internal implementation details.

## Out of Scope

- package installation or full bootstrap automation
- system provisioning
- `/etc` management during the first migration pass
- distro-specific package management workflows
- a redesign of all configs into separate desktop/server profiles
- rewriting every app config from scratch
- changing machine behavior that is already working unless it is required for portability
- replacing the repo with a different project structure entirely

## Further Notes

- `pixelpirate` is a Debian server, but it still uses the same userland configs during SSH sessions, so the migration must keep that workflow intact.
- The future laptop should inherit `velvet` by default, with only small overrides if needed later.
- The first migration should optimize for safety and readability over completeness.
- Once the userland migration is stable, system-level files can be evaluated as a separate follow-up.
