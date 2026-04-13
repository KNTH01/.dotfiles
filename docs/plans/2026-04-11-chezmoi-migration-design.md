# Chezmoi Migration Design

## Goal

Migrate the current GNU Stow-managed dotfiles repo to **chezmoi** while keeping the active workflow safe on `velvet`, preserving a familiar core CLI environment on `pixelpirate`, and making future laptop onboarding explicit and low-friction.

The approved phase 1 outcome is:

- `chezmoi` becomes the manager for the first core slice
- `~/.dotfiles` remains the only Git source repo
- the actual chezmoi source state lives under `home/`
- `pixelpirate` receives only the core CLI/userland slice
- encrypted Git identity moves into an age-encrypted chezmoi file
- `nvim`, desktop/UI configs, `zsh`, and system-level config are deferred

## Scope

### Phase 1

Phase 1 migrates:

- chezmoi scaffolding and machine data
- `git`
- encrypted `~/.gitconfig.user`
- `tmux`
- `mise`
- `fish`
- CLI-safe helper scripts that should live in `~/.local/bin`
- README / legacy workflow documentation updates

### Deferred from phase 1

These stay out until the core migration is stable:

- `nvim`
- desktop/UI config (`wezterm`, `alacritty`, `rofi`, `polybar`, `awesome`, `xmonad`, `vivaldi`, etc.)
- `zsh`
- `/etc` and other system-level files
- package installation / bootstrap automation
- a full secrets sweep beyond `~/.gitconfig.user`

## Current branch status note (2026-04-12)

The actual branch outcome for phase 1 is summarized in:

- `docs/plans/2026-04-12-chezmoi-phase1-status-and-next-steps.md`

Use that status doc as the source of truth for what actually landed, what changed during review, and what to do next. This design doc still captures the original approved shape, but several concrete filenames and the validation approach changed during execution.

## Key Decisions From the Grilling Session

- **Manager:** choose `chezmoi` now; do not pause for a broader tooling evaluation.
- **Repository model:** keep `/home/knth/.dotfiles` as the source-of-truth repo.
- **Source root:** use `.chezmoiroot` with `home`.
- **Machine model:** keep minimal repo-tracked machine data and fail closed for unknown hosts.
- **Branching strategy:** prefer shared config + optional-tool checks + portable paths before hostname branching.
- **Server policy:** `pixelpirate` gets core CLI/userland only, not desktop/UI payload.
- **Secrets:** use `age`, reuse the existing local gopass age identity, keep public recipients in Git, keep private identities local.
- **Generated artifacts:** do not track generated Fish completions, Fisher vendor state, or `fish_variables`.
- **Fish bootstrap:** do not auto-install Fisher plugins during `chezmoi apply`.
- **Mise bootstrap:** do not auto-run `mise install` during `chezmoi apply`.
- **Backup policy:** no separate backup workflow beyond Git for tracked files.
- **Stow transition:** retire the broad Stow installer/docs as the primary workflow as soon as phase 1 lands.

## Repo and Local Configuration Model

### Repo layout

The repo root remains the repo root. The chezmoi source state is narrowed to `home/` via `.chezmoiroot`.

```text
/home/knth/.dotfiles/
  .chezmoiroot
  README.md
  chezmoi/
    age/
      recipients.txt
  docs/
    prd/
    plans/
  home/
    .chezmoidata/
      machines.yaml
    dot_gitconfig
    encrypted_dot_gitconfig.user.age
    dot_tmux.conf
    dot_config/
      fish/
      mise/
    dot_local/
      bin/
```

`.chezmoiroot` contains:

```text
home
```

That keeps all target-state files inside `home/`, while docs and migration assets stay at repo root.

### Local chezmoi config

chezmoi itself must be pointed at `/home/knth/.dotfiles` instead of the default `~/.local/share/chezmoi` source directory.

The machine-local config file should be:

`/home/knth/.config/chezmoi/chezmoi.toml`

Example:

```toml
sourceDir = "/home/knth/.dotfiles"
encryption = "age"

[age]
    identities = ["/home/knth/.config/gopass/age/identities"]
```

This file is intentionally **local-only** and not tracked in Git.

### Existing default chezmoi source dir

`/home/knth/.local/share/chezmoi` is treated as stale/default chezmoi state, not as an active source repo. Once phase 1 is working, it should be retired so there is only one source of truth.

## Machine Model

### Repo-tracked machine data

Minimal machine metadata lives in:

`/home/knth/.dotfiles/home/.chezmoidata/machines.yaml`

Initial shape:

```yaml
machines:
  velvet:
    isDesktop: true
  pixelpirate:
    isDesktop: false
```

This is intentionally small. It should not grow a full inventory model unless a real need appears.

### Unknown-host policy

Unknown hosts must **fail closed**.

That means:

- common core config can still render
- desktop-only behavior must default to **off**
- a new laptop must be explicitly added to `machines.yaml` before it should be treated as desktop-like

### Branching policy

Use this decision order when a config differs between machines:

1. shared config and portable paths
2. optional-tool checks such as `type -q`, `command -v`, file existence, or `$HOME`
3. hostname-based behavior for true exceptions

Avoid creating broad Arch-vs-Debian config forks unless a real config file truly requires it.

## Secrets and Encryption

### Identity model

Each machine keeps its own local age identity.

For the current machines, reuse the existing local identity file:

`/home/knth/.config/gopass/age/identities`

Private identities never enter the repo.

### Public recipients

The canonical public recipient list should live in the repo at:

`/home/knth/.dotfiles/chezmoi/age/recipients.txt`

Recommended format:

```text
age1...
age1...
```

One public recipient per line.

This file is safe to version because the recipients are public.

### How encryption is used

Start with one encrypted file only:

- `~/.gitconfig.user`

Because the local chezmoi config intentionally keeps identities local, encryption and re-encryption commands should explicitly use the repo-tracked public recipient file via `--age-recipient-file` when needed.

### New-machine onboarding

When a new laptop is added:

1. generate or expose the machine’s local age identity
2. derive its public recipient
3. add its hostname to `home/.chezmoidata/machines.yaml`
4. add its public recipient to `chezmoi/age/recipients.txt`
5. re-encrypt secrets
6. run `chezmoi diff` and `chezmoi apply --dry-run`

## Phase 1 File Mapping

### Git

Current:

- `gitconfig/.gitconfig`
- local `~/.gitconfig.user`

Target:

- `home/dot_gitconfig`
- `home/encrypted_dot_gitconfig.user.age`

Notes:

- Keep the include boundary exactly as it works now.
- `~/.gitconfig.user` is the first and only encrypted secret in phase 1.

### tmux

Current:

- `tmux/.tmux.conf`

Target:

- `home/dot_tmux.conf`

Notes:

- This is a straightforward static migration.
- It is a good early low-risk cutover after Git.

### mise

Current:

- local `/home/knth/.config/mise/config.toml`

Target:

- `home/dot_config/mise/config.toml`

Notes:

- Track the existing config as source-of-truth.
- Do not add a machine override system yet.
- Do not auto-run `mise install` from chezmoi.

### Fish

Current:

- `fish/.config/fish/config.fish`
- `fish/.config/fish/conf.d/*`
- `fish/.config/fish/functions/*`
- `fish/.config/fish/fish_plugins`
- `fish/.config/fish/install_fisher.sh`
- `fish/.config/fish/install_fisher_plugins.sh`
- generated/vendor/local state mixed into the tree

Target:

- `home/dot_config/fish/config.fish`
- split `conf.d/` files by concern
- hand-written functions only
- `fish_plugins`
- documented manual Fisher bootstrap scripts

Recommended split:

```text
home/dot_config/fish/
  config.fish
  fish_plugins
  install_fisher.sh
  install_fisher_plugins.sh
  conf.d/
    00-core-paths.fish
    10-optional-tools.fish
    20-prompt.fish
    30-atuin-env.fish
    40-deno.fish
    50-arch-maintenance.fish
  functions/
    fish_greeting.fish
    fish_user_key_bindings.fish
    web2app.fish.tmpl
    web2app-remove.fish.tmpl
```

Fish-specific rules:

- keep `config.fish` thin
- use `conf.d/` files for paths, optional tools, prompt, and machine-specific extras
- replace hardcoded paths with `$HOME` where practical
- remove `fish_add_path ~/.dotfiles/bin` in favor of `~/.local/bin`
- guard optional tools like `mise`, `starship`, `zoxide`, `fzf`, `atuin`, and `fastfetch`
- keep Arch maintenance aliases isolated rather than mixed with shared shell startup
- treat desktop-only Fish functions as migrated files that are gated when Fish migrates

Do **not** manage these as source-of-truth in chezmoi:

- `fish/.config/fish/fisher/`
- `fish/.config/fish/fish_variables`
- generated completions like `deno.fish` and `mise.fish`

These must be rebuildable from package/tool installation or from the documented Fish bootstrap step.

### CLI-safe scripts

Current:

- `bin/cheat`
- `bin/omarchy-webapp-install`

Target in phase 1:

- `home/dot_local/bin/executable_cheat`

Deferred:

- desktop-specific helpers like `omarchy-webapp-install`

The goal is to standardize on `~/.local/bin` rather than `~/.dotfiles/bin`.

## Deferred Slices

### Neovim

`nvim` is intentionally deferred even though it is important.

Reason:

- with normal chezmoi behavior, the source of truth moves to `home/dot_config/nvim/...`
- that is a bigger workflow change for a live-edited Neovim config than for the other phase 1 files

Deferring it keeps phase 1 lower-risk.

### Desktop/UI configs

Desktop/UI config will become a later slice.

Examples:

- `wezterm`
- `alacritty`
- `rofi`
- `polybar`
- `awesome`
- `xmonad`
- `vivaldi`

When those files migrate, desktop/server gating should be introduced **only for those migrated files**.

### zsh

`zsh` is out of scope for now because it is no longer part of the active workflow.

## Hybrid Migration Strategy

During phase 1 there is a temporary hybrid period:

- chezmoi manages migrated paths
- Stow only remains relevant for untouched, unmigrated areas

Critical rule:

> Stow and chezmoi must never own the same target path at the same time.

Consequences:

- broad `install.sh` Stow usage becomes a footgun
- migrated paths must move into `home/` immediately
- once a path is migrated, README and installer guidance must stop telling the user to manage it with Stow

## Validation Strategy

Validation should be small, repeatable, and behavior-focused.

### Current branch outcome

During execution, a repo-tracked shell validation harness was prototyped and then removed from the final PR after review.

The retained phase 1 validation model is therefore **manual smoke testing** on live machines.

### Manual verification

On each machine, run:

- `chezmoi status`
- `chezmoi diff`
- `chezmoi apply --dry-run`
- `chezmoi apply` when the diff is acceptable
- Fish smoke test
- tmux smoke test
- Git include/identity smoke test
- mise config presence check
- CLI script presence check in `~/.local/bin`
- `~/.local/bin/fish-regenerate-completions` when `deno` and `mise` are installed

Validation still needs to be run on both `velvet` and `pixelpirate`.

For the exact phase 1 branch handoff state and next actions, see:

- `docs/plans/2026-04-12-chezmoi-phase1-status-and-next-steps.md`

## Rollout Order

The approved rollout order is:

1. scaffolding (`.chezmoiroot`, local config, machine data, recipient file, validation harness)
2. `git` + encrypted `~/.gitconfig.user`
3. `tmux`
4. `mise`
5. `fish`
6. CLI-safe scripts in `~/.local/bin`
7. README / Stow workflow retirement and final verification

This order proves the age flow early, handles simple static files before Fish, and leaves the riskiest shell cutover until the basics are already working.

## Risks and Mitigations

### Risk: two source repos compete (`~/.dotfiles` and `~/.local/share/chezmoi`)

Mitigation:

- point local chezmoi config at `/home/knth/.dotfiles`
- retire the stale default source dir once phase 1 is working

### Risk: Fish migration breaks startup on `pixelpirate`

Mitigation:

- split Fish by concern
- guard optional tools
- exclude generated/vendor state
- keep a documented manual Fisher rebuild step

### Risk: machine-specific logic spreads everywhere

Mitigation:

- keep machine data minimal
- default unknown hosts to non-desktop behavior
- add gating only when a file actually migrates

### Risk: secrets drift between machines

Mitigation:

- keep public recipients in a single repo-tracked file
- keep private identities local only
- start with one encrypted secret, not a full sweep

### Risk: legacy Stow instructions remain usable after cutover

Mitigation:

- retire the broad Stow installer/docs in the same migration phase
- make chezmoi the primary documented workflow as soon as phase 1 lands

## Summary

Phase 1 is a deliberately narrow chezmoi migration:

- one Git repo at `/home/knth/.dotfiles`
- one source root under `home/`
- one minimal machine-data file under `home/.chezmoidata/`
- one local chezmoi config pointing to that repo
- one encrypted secret to prove the age workflow
- one shared-first CLI/userland slice for `velvet` and `pixelpirate`
- deferred `nvim`, desktop/UI, `zsh`, and system-level config until the core path is stable