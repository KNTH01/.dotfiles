# Two-Phase TypeScript LSP Migration Design

## Context

The current Neovim config uses `vtsls` for TypeScript/JavaScript and still contains Vue-specific wiring:

- Vue TypeScript plugin setup in `lua/knth/plugins/lsp/lspconfig.lua`
- `vue_ls` server setup in `lua/knth/plugins/lsp/lspconfig.lua`
- Vue formatter/linter mappings in `lua/knth/plugins/lsp/conform.lua` and `lua/knth/plugins/lsp/nvim-lint.lua`
- Vue filetype logging support in `lua/knth/plugins/logsitter.lua`

The user no longer works with Vue and wants a safe path toward `tsgo`, while keeping `@effect/language-service` support if possible.

## Goals

- Remove all Vue support from this Neovim config.
- Keep TypeScript/JavaScript editing stable after Vue removal.
- Preserve the existing `denols` vs TS server split.
- Preserve `@effect/language-service` support.
- Evaluate `tsgo` in a second phase instead of doing a risky one-shot switch.

## Non-Goals

- Changing the formatter/linter stack.
- Refactoring unrelated language server config.
- Forcing a `tsgo` migration if it cannot preserve Effect support.

## Decision

Use a two-phase migration:

### Phase 1: Remove Vue, keep `vtsls`

Scope:

- Remove Vue-specific LSP setup from `lua/knth/plugins/lsp/lspconfig.lua`
- Remove Vue mappings from `lua/knth/plugins/lsp/conform.lua`
- Remove Vue mappings from `lua/knth/plugins/lsp/nvim-lint.lua`
- Remove Vue support from `lua/knth/plugins/logsitter.lua`
- Keep `vtsls`
- Keep `denols` split logic
- Keep `@effect/language-service`

Why:

- Lowest-risk cleanup.
- Keeps current TS behavior stable.
- Removes dead Vue config immediately.
- Makes phase 2 easier to reason about.

### Phase 2: Evaluate `tsgo` without breaking Effect support

Scope:

- Investigate whether `tsgo` has a documented, supportable way to preserve `@effect/language-service`
- Only switch from `vtsls` to `tsgo` if that path is confirmed
- Otherwise stop after phase 1 and keep `vtsls`

Why:

- Local `nvim-lspconfig` docs clearly show TypeScript plugin wiring for `vtsls`/`ts_ls`
- Local `tsgo` docs do not show equivalent plugin wiring
- The migration should not remove an actively used Effect workflow just to change servers

## Risks

- `tsgo` may not support the same plugin-loading path as `vtsls`.
- `tsgo` is not currently installed in Mason packages in this environment.
- LSP behavior is harder to validate than plain Lua syntax, so verification must include focused regression checks.

## Verification Strategy

### Phase 1

- Add a headless regression script that fails while Vue-specific config is still present.
- Remove Vue config until the regression script passes.
- Run a headless module-load smoke check for the touched Lua modules.

### Phase 2

- Prove or disprove `tsgo` + Effect compatibility from local docs and installed packages before editing code.
- If compatibility is proven, create a dedicated follow-up implementation plan with exact config and verification steps.
- If compatibility is not proven, document the blocker and keep `vtsls`.

## Result

Proceed with a two-phase migration where phase 1 is an actual cleanup and phase 2 is a guarded evaluation. This keeps the config minimal now and avoids breaking Effect support on speculation.
