# Chezmoi Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate the approved phase 1 dotfiles slice from GNU Stow to chezmoi without breaking `velvet`, while keeping `pixelpirate` on the shared core CLI/userland path.

**Architecture:** Keep `/home/knth/.dotfiles` as the single Git source repo, point local chezmoi at that repo, and narrow the source state to `home/` with `.chezmoiroot`. Implement the migration in small slices, using checked-in shell validation scripts as the TDD mechanism for config behavior and render checks before each slice is cut over.

**Tech Stack:** chezmoi, age, shell validation scripts, Fish, tmux, mise, Git, Markdown docs

---

## Current branch execution status (2026-04-12)

This file is the **original execution plan**.

The actual branch outcome is summarized in:

- `docs/plans/2026-04-12-chezmoi-phase1-status-and-next-steps.md`

Important branch differences from this original plan:

- Tasks 1 through 6 are complete on `feat/chezmoi-migration-phase1`
- Task 7 was **not** implemented as written because the repo-tracked `tests/chezmoi/*` scripts were removed from the final PR after review
- final phase 1 validation on `velvet` is manual rather than checked-in shell tests
- the actual encrypted Git secret path is `home/encrypted_dot_gitconfig.user.age`
- the actual migrated CLI helper path is `home/dot_local/bin/executable_cheat`
- `home/dot_local/bin/executable_fish-regenerate-completions` was added during review
- these Fish files are plain `.fish`, not `.tmpl`:
  - `home/dot_config/fish/conf.d/00-core-paths.fish`
  - `home/dot_config/fish/conf.d/10-optional-tools.fish`
  - `home/dot_config/fish/conf.d/20-prompt.fish`
  - `home/dot_config/fish/conf.d/40-deno.fish`
  - `home/dot_config/fish/conf.d/50-arch-maintenance.fish`
  - `home/dot_config/fish/functions/fish_greeting.fish`

If resuming this work later, use the status doc above instead of assuming every filename and validation step in the original plan still matches the branch.

## TDD note for this plan

Most production changes here are configuration files, not application code. The implementation must still follow **@test-driven-development** by writing or updating a failing validation script before each config slice is migrated, running it to see the expected failure, making the minimal config change, and re-running the script until it passes.

The validation scripts for this plan live under:

- `tests/chezmoi/`

They should render the chezmoi source state into a temporary destination directory and assert on final rendered behavior.

### Task 1: Scaffold chezmoi source root, machine data, and local config

**Files:**
- Create: `.chezmoiroot`
- Create: `chezmoi/age/recipients.txt`
- Create: `home/.chezmoidata/machines.yaml`
- Create: `tests/chezmoi/00-scaffolding.sh`
- Modify locally only: `/home/knth/.config/chezmoi/chezmoi.toml`

**Step 1: Write the failing test**

Create `tests/chezmoi/00-scaffolding.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles

[[ "$(tr -d '\n' < "$repo/.chezmoiroot" 2>/dev/null)" == "home" ]]
[[ -f "$repo/home/.chezmoidata/machines.yaml" ]]
chezmoi -S "$repo" data --format=yaml | rg '^machines:'
[[ "$(chezmoi source-path)" == "$repo" ]]
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/00-scaffolding.sh
```

Expected: FAIL because `.chezmoiroot`, `home/.chezmoidata/machines.yaml`, or the local `sourceDir` setting do not exist yet.

**Step 3: Write minimal implementation**

Create `.chezmoiroot`:

```text
home
```

Create `home/.chezmoidata/machines.yaml`:

```yaml
machines:
  velvet:
    isDesktop: true
  pixelpirate:
    isDesktop: false
```

Create `chezmoi/age/recipients.txt` with one public recipient per line:

```text
age1<velvet-public-recipient>
age1<pixelpirate-public-recipient>
```

Create or update the local file `/home/knth/.config/chezmoi/chezmoi.toml`:

```toml
sourceDir = "/home/knth/.dotfiles"
encryption = "age"

[age]
    identities = ["/home/knth/.config/gopass/age/identities"]
```

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/00-scaffolding.sh
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/knth/.dotfiles add \
  /home/knth/.dotfiles/.chezmoiroot \
  /home/knth/.dotfiles/chezmoi/age/recipients.txt \
  /home/knth/.dotfiles/home/.chezmoidata/machines.yaml \
  /home/knth/.dotfiles/tests/chezmoi/00-scaffolding.sh

git -C /home/knth/.dotfiles commit -m "feat: scaffold chezmoi source root"
```

### Task 2: Migrate Git config and encrypted Git identity

**Files:**
- Modify: `gitconfig/.gitconfig`
- Create: `home/dot_gitconfig`
- Create: `home/encrypted_private_dot_gitconfig.user`
- Create: `tests/chezmoi/10-git.sh`
- Delete after cutover: `gitconfig/.gitconfig` (once source state is verified)

**Step 1: Write the failing test**

Create `tests/chezmoi/10-git.sh`:

```bash
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
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/10-git.sh
```

Expected: FAIL because the chezmoi source state does not yet contain `dot_gitconfig` and the encrypted private file.

**Step 3: Write minimal implementation**

Copy the current tracked Git config into the source state:

- move `/home/knth/.dotfiles/gitconfig/.gitconfig` to `/home/knth/.dotfiles/home/dot_gitconfig`
- keep the include of `~/.gitconfig.user` unchanged

Add the current private identity file as encrypted source state:

```bash
chezmoi -S /home/knth/.dotfiles \
  --age-recipient-file /home/knth/.dotfiles/chezmoi/age/recipients.txt \
  add --encrypt /home/knth/.gitconfig.user
```

Confirm the encrypted output lands at:

- `/home/knth/.dotfiles/home/encrypted_private_dot_gitconfig.user`

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/10-git.sh
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/knth/.dotfiles add \
  /home/knth/.dotfiles/home/dot_gitconfig \
  /home/knth/.dotfiles/home/encrypted_private_dot_gitconfig.user \
  /home/knth/.dotfiles/tests/chezmoi/10-git.sh

git -C /home/knth/.dotfiles commit -m "feat: migrate git config to chezmoi"
```

### Task 3: Migrate tmux

**Files:**
- Create: `home/dot_tmux.conf`
- Create: `tests/chezmoi/20-tmux.sh`
- Delete after cutover: `tmux/.tmux.conf`

**Step 1: Write the failing test**

Create `tests/chezmoi/20-tmux.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

chezmoi -S "$repo" apply -D "$tmpdir" --force

test -f "$tmpdir/.tmux.conf"
rg '^set-option -g default-shell /usr/bin/fish$' "$tmpdir/.tmux.conf"
tmux -f "$tmpdir/.tmux.conf" start-server \; kill-server
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/20-tmux.sh
```

Expected: FAIL because `home/dot_tmux.conf` does not exist yet.

**Step 3: Write minimal implementation**

Move the current tracked tmux config into the source state:

- `/home/knth/.dotfiles/tmux/.tmux.conf`
- → `/home/knth/.dotfiles/home/dot_tmux.conf`

Do not change behavior beyond what is needed for the path migration.

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/20-tmux.sh
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/knth/.dotfiles add \
  /home/knth/.dotfiles/home/dot_tmux.conf \
  /home/knth/.dotfiles/tests/chezmoi/20-tmux.sh

git -C /home/knth/.dotfiles commit -m "feat: migrate tmux config to chezmoi"
```

### Task 4: Migrate mise config without auto-install behavior

**Files:**
- Create: `home/dot_config/mise/config.toml`
- Create: `tests/chezmoi/30-mise.sh`

**Step 1: Write the failing test**

Create `tests/chezmoi/30-mise.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

chezmoi -S "$repo" apply -D "$tmpdir" --force

test -f "$tmpdir/.config/mise/config.toml"
rg '^chezmoi = "latest"$' "$tmpdir/.config/mise/config.toml"
rg '^"npm:@ccusage/opencode" = "latest"$' "$tmpdir/.config/mise/config.toml"
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/30-mise.sh
```

Expected: FAIL because the current local mise config is not yet tracked in chezmoi.

**Step 3: Write minimal implementation**

Copy the current local mise config into the source state:

- `/home/knth/.config/mise/config.toml`
- → `/home/knth/.dotfiles/home/dot_config/mise/config.toml`

Do not add auto-install hooks. Keep this as a tracked manifest only.

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/30-mise.sh
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/knth/.dotfiles add \
  /home/knth/.dotfiles/home/dot_config/mise/config.toml \
  /home/knth/.dotfiles/tests/chezmoi/30-mise.sh

git -C /home/knth/.dotfiles commit -m "feat: track mise config in chezmoi"
```

### Task 5: Migrate Fish as hand-written source plus rebuildable generated state

**Files:**
- Create: `home/dot_config/fish/config.fish`
- Create: `home/dot_config/fish/fish_plugins`
- Create: `home/dot_config/fish/install_fisher.sh`
- Create: `home/dot_config/fish/install_fisher_plugins.sh`
- Create: `home/dot_config/fish/conf.d/00-core-paths.fish.tmpl`
- Create: `home/dot_config/fish/conf.d/10-optional-tools.fish.tmpl`
- Create: `home/dot_config/fish/conf.d/20-prompt.fish.tmpl`
- Create: `home/dot_config/fish/conf.d/30-atuin-env.fish`
- Create: `home/dot_config/fish/conf.d/40-deno.fish.tmpl`
- Create: `home/dot_config/fish/conf.d/50-arch-maintenance.fish.tmpl`
- Create: `home/dot_config/fish/functions/fish_greeting.fish.tmpl`
- Create: `home/dot_config/fish/functions/fish_user_key_bindings.fish`
- Create: `home/dot_config/fish/functions/web2app.fish.tmpl`
- Create: `home/dot_config/fish/functions/web2app-remove.fish.tmpl`
- Create: `tests/chezmoi/40-fish.sh`
- Delete from source-of-truth: generated/vendor files under `fish/.config/fish/fisher/`, `fish_variables`, `completions/deno.fish`, `completions/mise.fish`

**Step 1: Write the failing test**

Create `tests/chezmoi/40-fish.sh`:

```bash
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
env HOME="$tmpdir" XDG_CONFIG_HOME="$tmpdir/.config" fish -i -c exit >/dev/null 2>"$tmpdir/fish.stderr"
test ! -s "$tmpdir/fish.stderr"
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/40-fish.sh
```

Expected: FAIL because Fish is not yet represented correctly in `home/` and still depends on generated/local artifacts and legacy paths.

**Step 3: Write minimal implementation**

Migrate Fish as hand-written source only.

Implementation rules:

- keep `config.fish` thin
- move path setup, optional tooling, prompt setup, and Arch maintenance aliases into separate `conf.d/` files
- replace hardcoded home paths with `$HOME` where practical
- guard optional tools (`mise`, `zoxide`, `fzf`, `atuin`, `starship`, `fastfetch`, etc.)
- stop referencing `~/.dotfiles/bin`; use `~/.local/bin`
- keep `fish_plugins` and the manual Fisher install scripts
- make desktop-only Fish functions render only on desktop hosts
- do **not** track generated completions, Fisher vendor output, or `fish_variables`

Minimal file content expectations:

`home/dot_config/fish/functions/fish_greeting.fish.tmpl`

```fish
function fish_greeting
    if type -q fastfetch
        fastfetch
    end
end
```

`home/dot_config/fish/conf.d/40-deno.fish.tmpl`

```fish
if test -f "$HOME/.deno/env.fish"
    source "$HOME/.deno/env.fish"
end
```

`home/dot_config/fish/conf.d/10-optional-tools.fish.tmpl`

```fish
if type -q zoxide
    zoxide init --cmd cd fish | source
end

if type -q fzf
    fzf --fish | source
end

if type -q atuin
    atuin init fish | source
end

if type -q mise
    mise activate fish | source
end
```

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/40-fish.sh
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/knth/.dotfiles add \
  /home/knth/.dotfiles/home/dot_config/fish \
  /home/knth/.dotfiles/tests/chezmoi/40-fish.sh

git -C /home/knth/.dotfiles commit -m "feat: migrate fish config to chezmoi"
```

### Task 6: Migrate CLI-safe scripts to ~/.local/bin and retire broad Stow workflow

**Files:**
- Create: `home/executable_dot_local/bin/cheat`
- Create: `tests/chezmoi/50-bin-and-docs.sh`
- Modify: `README.md`
- Modify: `install.sh`
- Leave deferred: `bin/omarchy-webapp-install`

**Step 1: Write the failing test**

Create `tests/chezmoi/50-bin-and-docs.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

chezmoi -S "$repo" apply -D "$tmpdir" --force

test -x "$tmpdir/.local/bin/cheat"
test ! -e "$tmpdir/.local/bin/omarchy-webapp-install"
rg 'chezmoi' "$repo/README.md"
! rg -n '^\$> stow \$folder$' "$repo/README.md"
rg 'retired|legacy|chezmoi' "$repo/install.sh"
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/50-bin-and-docs.sh
```

Expected: FAIL because `cheat` is not yet in `home/executable_dot_local/bin`, README still centers Stow, or `install.sh` still performs broad Stow actions.

**Step 3: Write minimal implementation**

- move `/home/knth/.dotfiles/bin/cheat` to `/home/knth/.dotfiles/home/executable_dot_local/bin/cheat`
- leave `omarchy-webapp-install` deferred for the later desktop slice
- rewrite `README.md` so chezmoi is the primary workflow
- replace the old broad Stow installer in `install.sh` with a short retired/legacy message and non-zero exit

Recommended `install.sh` content:

```bash
#!/usr/bin/env bash

echo "install.sh is retired for migrated paths. Use chezmoi for phase 1 dotfiles management."
exit 1
```

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/50-bin-and-docs.sh
```

Expected: PASS.

**Step 5: Commit**

```bash
git -C /home/knth/.dotfiles add \
  /home/knth/.dotfiles/home/executable_dot_local/bin/cheat \
  /home/knth/.dotfiles/README.md \
  /home/knth/.dotfiles/install.sh \
  /home/knth/.dotfiles/tests/chezmoi/50-bin-and-docs.sh

git -C /home/knth/.dotfiles commit -m "feat: move cli scripts and retire stow installer"
```

### Task 7: Add an aggregator validation script and run full phase 1 verification

**Files:**
- Create: `tests/chezmoi/run-phase1.sh`
- Create: `docs/plans/chezmoi-phase1-validation-checklist.md`

**Step 1: Write the failing test**

Create `tests/chezmoi/run-phase1.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

repo=/home/knth/.dotfiles

bash "$repo/tests/chezmoi/00-scaffolding.sh"
bash "$repo/tests/chezmoi/10-git.sh"
bash "$repo/tests/chezmoi/20-tmux.sh"
bash "$repo/tests/chezmoi/30-mise.sh"
bash "$repo/tests/chezmoi/40-fish.sh"
bash "$repo/tests/chezmoi/50-bin-and-docs.sh"
```

Create `docs/plans/chezmoi-phase1-validation-checklist.md` with these manual commands:

```markdown
# Chezmoi Phase 1 Validation Checklist

## Velvet
- `chezmoi diff`
- `chezmoi apply --dry-run`
- `bash tests/chezmoi/run-phase1.sh`
- `fish -i -c exit`
- `tmux -f ~/.tmux.conf start-server \; kill-server`
- `git config --file ~/.gitconfig --get include.path`
- `test -f ~/.config/mise/config.toml`
- `test -x ~/.local/bin/cheat`

## Pixelpirate
- `chezmoi diff`
- `chezmoi apply --dry-run`
- `bash tests/chezmoi/run-phase1.sh`
- `fish -i -c exit`
- `tmux -f ~/.tmux.conf start-server \; kill-server`
- `git config --file ~/.gitconfig --get include.path`
- `test -f ~/.config/mise/config.toml`
- `test -x ~/.local/bin/cheat`
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/run-phase1.sh
```

Expected: FAIL until every earlier task is complete and the aggregator exists.

**Step 3: Write minimal implementation**

Create the aggregator script and the checklist exactly as above.

Then run the full local verification on `velvet`:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/run-phase1.sh
chezmoi -S /home/knth/.dotfiles diff
chezmoi -S /home/knth/.dotfiles apply --dry-run
```

After the branch is available on `pixelpirate`, run the same checklist there.

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles && bash tests/chezmoi/run-phase1.sh
```

Expected: PASS locally on `velvet`, then PASS again on `pixelpirate` once the branch is checked out there.

**Step 5: Commit**

```bash
git -C /home/knth/.dotfiles add \
  /home/knth/.dotfiles/tests/chezmoi/run-phase1.sh \
  /home/knth/.dotfiles/docs/plans/chezmoi-phase1-validation-checklist.md

git -C /home/knth/.dotfiles commit -m "docs: add chezmoi phase 1 validation flow"
```