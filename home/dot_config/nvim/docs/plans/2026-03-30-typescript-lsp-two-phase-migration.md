# TypeScript LSP Two-Phase Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove all Vue support from the Neovim config, keep the current `vtsls` + Effect workflow intact, and then explicitly prove whether a safe `tsgo` migration exists.

**Architecture:** Phase 1 is a direct cleanup of dead Vue-specific config while preserving `vtsls`, `denols`, and `@effect/language-service`. Phase 2 is intentionally gated by research: only if local docs and installed packages show a supportable `tsgo` + Effect path should a second implementation plan be written for the actual server swap.

**Tech Stack:** Lua, Neovim 0.11 LSP, `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim`, `conform.nvim`, `nvim-lint`, `logsitter.nvim`, `vtsls`, `denols`, `tsgo`, `@effect/language-service`

---

### Task 1: Remove Vue from formatter/linter/logging config

**Files:**
- Create: `tests/headless/phase1_no_vue_tools.lua`
- Modify: `lua/knth/plugins/lsp/conform.lua:9-23`
- Modify: `lua/knth/plugins/lsp/nvim-lint.lua:41-49`
- Modify: `lua/knth/plugins/logsitter.lua:16-19`
- Test: `tests/headless/phase1_no_vue_tools.lua`

**Step 1: Write the failing test**

```lua
local root = vim.fn.getcwd()

local function read(rel)
  return table.concat(vim.fn.readfile(root .. "/" .. rel), "\n")
end

local conform = read("lua/knth/plugins/lsp/conform.lua")
assert(not conform:find('vue = { js_formatter }', 1, true), "remove vue formatter mapping")

local lint = read("lua/knth/plugins/lsp/nvim-lint.lua")
assert(not lint:find('vue = { js_linter }', 1, true), "remove vue lint mapping")

local logsitter = read("lua/knth/plugins/logsitter.lua")
assert(not logsitter:find('{ "vue", "astro", "svelte" }', 1, true), "remove vue logsitter mapping")

print("phase1_no_vue_tools: ok")
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles/home/dot_config/nvim && nvim --headless "+lua dofile('tests/headless/phase1_no_vue_tools.lua')" +qa
```

Expected: FAIL with at least one Vue-related assertion.

**Step 3: Write minimal implementation**

In `lua/knth/plugins/lsp/conform.lua`, change:

```lua
		local formatters_by_ft = {
			javascript = { js_formatter },
			typescript = { js_formatter },
			javascriptreact = { js_formatter },
			typescriptreact = { js_formatter },
			vue = { js_formatter },
			astro = { js_formatter },
```

to:

```lua
		local formatters_by_ft = {
			javascript = { js_formatter },
			typescript = { js_formatter },
			javascriptreact = { js_formatter },
			typescriptreact = { js_formatter },
			astro = { js_formatter },
```

In `lua/knth/plugins/lsp/nvim-lint.lua`, change:

```lua
		lint.linters_by_ft = {
			javascript = { js_linter },
			typescript = { js_linter },
			javascriptreact = { js_linter },
			typescriptreact = { js_linter },
			svelte = { js_linter },
			vue = { js_linter },
			astro = { js_linter },
```

to:

```lua
		lint.linters_by_ft = {
			javascript = { js_linter },
			typescript = { js_linter },
			javascriptreact = { js_linter },
			typescriptreact = { js_linter },
			svelte = { js_linter },
			astro = { js_linter },
```

In `lua/knth/plugins/logsitter.lua`, change:

```lua
		logsitter.register(javascript_logger, { "vue", "astro", "svelte" })
```

to:

```lua
		logsitter.register(javascript_logger, { "astro", "svelte" })
```

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles/home/dot_config/nvim && nvim --headless "+lua dofile('tests/headless/phase1_no_vue_tools.lua')" +qa
```

Expected: PASS and print `phase1_no_vue_tools: ok`.

**Step 5: Commit**

```bash
cd /home/knth/.dotfiles && git add home/dot_config/nvim/tests/headless/phase1_no_vue_tools.lua home/dot_config/nvim/lua/knth/plugins/lsp/conform.lua home/dot_config/nvim/lua/knth/plugins/lsp/nvim-lint.lua home/dot_config/nvim/lua/knth/plugins/logsitter.lua && git commit -m "nvim: remove vue tool mappings"
```

### Task 2: Remove Vue from LSP config while keeping `vtsls`, `denols`, and Effect

**Files:**
- Create: `tests/headless/phase1_no_vue_lsp.lua`
- Modify: `lua/knth/plugins/lsp/lspconfig.lua:69-197`
- Test: `tests/headless/phase1_no_vue_lsp.lua`

**Step 1: Write the failing test**

```lua
local root = vim.fn.getcwd()

local function read(rel)
  return table.concat(vim.fn.readfile(root .. "/" .. rel), "\n")
end

local lsp = read("lua/knth/plugins/lsp/lspconfig.lua")

assert(lsp:find("vtsls = {", 1, true), "phase 1 should keep vtsls")
assert(lsp:find("denols = {", 1, true), "phase 1 should keep denols")
assert(lsp:find("@effect/language-service", 1, true), "phase 1 must keep effect support")
assert(not lsp:find("tsgo = {", 1, true), "phase 1 must not switch to tsgo yet")
assert(not lsp:find("vue_language_server_path", 1, true), "remove vue language server path")
assert(not lsp:find("@vue/typescript-plugin", 1, true), "remove vue typescript plugin")
assert(not lsp:find('filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }', 1, true), "remove vue from vtsls filetypes")
assert(not lsp:find("vue_ls = {", 1, true), "remove vue_ls config")

print("phase1_no_vue_lsp: ok")
```

**Step 2: Run test to verify it fails**

Run:

```bash
cd /home/knth/.dotfiles/home/dot_config/nvim && nvim --headless "+lua dofile('tests/headless/phase1_no_vue_lsp.lua')" +qa
```

Expected: FAIL with one or more Vue-related assertions.

**Step 3: Write minimal implementation**

Delete the whole Vue language server path block in `lua/knth/plugins/lsp/lspconfig.lua`:

```lua
			-- Use the stable approach recommended by Mason documentation for Mason 2
			local vue_language_server_path =
				vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server")

			-- Check if the directory exists
			if vim.fn.isdirectory(vue_language_server_path) == 0 then
				print("Warning: Vue language server directory not found at: " .. vue_language_server_path)
				print("Make sure you have installed vue-language-server with Mason")
				-- You could return here or set a fallback path
			end
```

Replace the `globalPlugins` block inside `vtsls.settings.vtsls.tsserver` with an Effect-only version:

```lua
						vtsls = {
							tsserver = {
								globalPlugins = has_effect_ls and {
									{
										name = "@effect/language-service",
										location = effect_ls_path,
										languages = { "typescript" },
										configNamespace = "typescript",
									},
								} or {},
							},
						},
```

Change the `vtsls.filetypes` entry from:

```lua
					filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
```

to:

```lua
					filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
```

Delete the whole `vue_ls` block:

```lua
				-- vue_ls = {},
				vue_ls = {
					-- fix Snacks opening vue files (Dashboard, Picker)
					init_options = {
						typescript = {
							tsdk = vim.fn.expand(
								"$MASON/packages/typescript-language-server/node_modules/typescript/lib"
							),
						},
					},
				},
```

**Step 4: Run test to verify it passes**

Run:

```bash
cd /home/knth/.dotfiles/home/dot_config/nvim && nvim --headless "+lua dofile('tests/headless/phase1_no_vue_lsp.lua')" +qa
```

Expected: PASS and print `phase1_no_vue_lsp: ok`.

**Step 5: Commit**

```bash
cd /home/knth/.dotfiles && git add home/dot_config/nvim/tests/headless/phase1_no_vue_lsp.lua home/dot_config/nvim/lua/knth/plugins/lsp/lspconfig.lua && git commit -m "nvim: remove vue lsp config"
```

### Task 3: Run phase 1 smoke validation

**Files:**
- Test: `tests/headless/phase1_no_vue_tools.lua`
- Test: `tests/headless/phase1_no_vue_lsp.lua`

**Step 1: Re-run both regression tests**

Run:

```bash
cd /home/knth/.dotfiles/home/dot_config/nvim && nvim --headless "+lua dofile('tests/headless/phase1_no_vue_tools.lua')" +qa && nvim --headless "+lua dofile('tests/headless/phase1_no_vue_lsp.lua')" +qa
```

Expected: both PASS.

**Step 2: Run a module-load smoke check**

Run:

```bash
cd /home/knth/.dotfiles/home/dot_config/nvim && nvim --headless "+lua require('knth.plugins.lsp.conform'); require('knth.plugins.lsp.nvim-lint'); require('knth.plugins.logsitter'); require('knth.plugins.lsp.lspconfig')" +qa
```

Expected: exit code 0 with no Lua errors.

**Step 3: Open a real TypeScript file and confirm `vtsls` is still the intended TS server**

Run:

```bash
cd /home/knth/.dotfiles/home/dot_config/nvim && printf 'const answer: number = 42\n' > /tmp/pi-ts-phase1.ts && nvim --headless /tmp/pi-ts-phase1.ts "+lua print(vim.bo.filetype)" +qa
```

Expected: output includes `typescript`.

**Step 4: Commit**

```bash
cd /home/knth/.dotfiles && git add home/dot_config/nvim/tests/headless/phase1_no_vue_tools.lua home/dot_config/nvim/tests/headless/phase1_no_vue_lsp.lua home/dot_config/nvim/lua/knth/plugins/lsp/conform.lua home/dot_config/nvim/lua/knth/plugins/lsp/nvim-lint.lua home/dot_config/nvim/lua/knth/plugins/logsitter.lua home/dot_config/nvim/lua/knth/plugins/lsp/lspconfig.lua && git commit -m "nvim: drop vue support"
```

### Task 4: Prove or disprove `tsgo` + Effect compatibility before editing code

**Files:**
- Modify: `docs/plans/2026-03-30-typescript-lsp-two-phase-migration-design.md`

**Step 1: Gather local evidence**

Run:

```bash
rg -n "tsgo|globalPlugins|plugins|@effect/language-service" /home/knth/.local/share/nvim/lazy/nvim-lspconfig /home/knth/.local/share/nvim/mason/packages /home/knth/.dotfiles/home/dot_config/nvim
```

Expected: evidence that `vtsls` documents plugin support and `tsgo` docs do not show an equivalent local plugin-loading path.

**Step 2: Record the decision in the design doc**

Append this section to `docs/plans/2026-03-30-typescript-lsp-two-phase-migration-design.md` with the actual evidence from step 1:

```md
## Phase 2 Research Outcome

- Decision: BLOCKED or PROCEED
- Reason: <one sentence>
- Evidence:
  - <path and finding>
  - <path and finding>
```

**Step 3: Decide the branch**

- If no supported `tsgo` + Effect wiring is documented locally, go to Task 5A.
- If a supported, explicit `tsgo` + Effect wiring is found and understood, go to Task 5B.

**Step 4: Commit**

```bash
cd /home/knth/.dotfiles && git add home/dot_config/nvim/docs/plans/2026-03-30-typescript-lsp-two-phase-migration-design.md && git commit -m "docs: record tsgo evaluation"
```

### Task 5A: Stop safely if `tsgo` cannot preserve Effect support

**Files:**
- Modify: `docs/plans/2026-03-30-typescript-lsp-two-phase-migration-design.md`

**Step 1: Write the conclusion**

Append a short final note to the design doc:

```md
## Final Phase 2 Status

Phase 2 stops here. `vtsls` remains the TypeScript/JavaScript server because local documentation did not provide a safe, explicit path for preserving `@effect/language-service` under `tsgo`.
```

**Step 2: Verify phase 1 state is still green**

Run:

```bash
cd /home/knth/.dotfiles/home/dot_config/nvim && nvim --headless "+lua dofile('tests/headless/phase1_no_vue_tools.lua')" +qa && nvim --headless "+lua dofile('tests/headless/phase1_no_vue_lsp.lua')" +qa
```

Expected: both PASS.

**Step 3: Commit**

```bash
cd /home/knth/.dotfiles && git add home/dot_config/nvim/docs/plans/2026-03-30-typescript-lsp-two-phase-migration-design.md && git commit -m "docs: keep vtsls after tsgo evaluation"
```

### Task 5B: If `tsgo` + Effect is proven, stop and write a new exact follow-up plan

**Files:**
- Create: `docs/plans/2026-03-30-tsgo-follow-up.md`

**Step 1: Do not edit `lspconfig.lua` yet**

Before touching production config, write a follow-up plan that includes the exact supported `tsgo` + Effect snippet discovered in Task 4.

**Step 2: Use this exact header**

```md
# tsgo Follow-Up Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace `vtsls` with `tsgo` without losing `@effect/language-service` support.

**Architecture:** Use the exact `tsgo` configuration proven in the phase 2 research step. Keep the `denols` split intact. Do not remove the old `vtsls` block until a failing regression test exists for the new `tsgo` state.

**Tech Stack:** Lua, Neovim 0.11 LSP, `nvim-lspconfig`, `tsgo`, `denols`, `@effect/language-service`

---
```

**Step 3: Include these mandatory sections in the follow-up plan**

- failing regression test for the `tsgo` state
- exact `lspconfig.lua` replacement code
- exact installation step for `tsgo`
- exact verification step proving `vtsls` is gone and `tsgo` is present
- rollback step back to the phase 1 `vtsls` state

**Step 4: Commit**

```bash
cd /home/knth/.dotfiles && git add home/dot_config/nvim/docs/plans/2026-03-30-tsgo-follow-up.md && git commit -m "docs: add tsgo follow-up plan"
```
