# Neovim 0.12 Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrer la config Neovim de 0.11 vers 0.12 (approche B+): fixer deprecations, retirer nvim-lspconfig/mason-lspconfig, rewrite treesitter pour la nouvelle API main, dropper les plugins obsolètes.

**Architecture:** Modifications ciblées sur lazy.nvim config existante. Keep: lazy.nvim, blink.cmp, mason. Drop: nvim-lspconfig, mason-lspconfig, nvim-lsp-file-operations + 6 plugins obsolètes. Refactor: lspconfig.lua → lsp.lua utilisant `vim.lsp.config()` natif. Rewrite: treesitter.lua pour API main branch.

**Tech Stack:** Neovim 0.12, Lua, lazy.nvim, blink.cmp, mason.nvim, nvim-treesitter (branch main), vtsls/denols/lua_ls/etc. LSPs. Config gérée par **chezmoi** depuis `~/.dotfiles/`.

---

## Workflow chezmoi — à chaque Task

1. **Éditer le fichier source** dans `~/.dotfiles/home/dot_config/nvim/...`
2. **Appliquer** avec `chezmoi apply`
3. **Tester** nvim (headless checks ou ouverture manuelle)
4. **Commit** dans `~/.dotfiles/` (branch `migration/nvim-0.12` déjà active)

Rollback = `git reset --hard HEAD~1` depuis `~/.dotfiles/`.

---

## File Structure

**Files à créer (source chezmoi):**
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/lsp/lsp.lua` — nouvelle config LSP native

**Files à modifier (source chezmoi):**
- `~/.dotfiles/home/dot_config/nvim/lua/knth/options.lua`
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/treesitter.lua`

**Files à supprimer (source chezmoi):**
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/lsp/lspconfig.lua`
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/comment.lua`
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/cellular-automaton.lua`
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/undotree.lua`
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/vista.lua`
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/ufo.lua`
- `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/oil-nvim.lua`

**Note:** `chezmoi apply` propage les suppressions? **À vérifier** — chezmoi par défaut ne supprime pas les fichiers du target quand ils disparaissent de la source. Pour les plugins drop, on peut:
- Option A: supprimer aussi manuellement dans `~/.config/nvim/lua/knth/plugins/` après edit source
- Option B: remplacer le contenu par un empty return (`return {}`) — garde le fichier mais le plugin ne se charge pas, fichier à drop plus tard

Recommandation: **Option A** (supprimer source + destination) pour propreté.

---

### Task 1: Baseline

**Files:**
- Create: `/tmp/nvim-baseline-checkhealth.txt`

- [ ] **Step 1: Vérifier qu'on est sur la bonne branche**

Run:
```bash
cd ~/.dotfiles && git status
```

Expected: `On branch migration/nvim-0.12`, working tree propre (ou juste les docs spec/plan stagés).

- [ ] **Step 2: Capture baseline checkhealth**

Run:
```bash
nvim --headless "+checkhealth" "+w /tmp/nvim-baseline-checkhealth.txt" "+qa" 2>&1
```

Expected: fichier `/tmp/nvim-baseline-checkhealth.txt` créé avec rapport complet.

- [ ] **Step 3: Identifier la source de `vim.tbl_flatten`**

Run:
```bash
grep -n "tbl_flatten" /tmp/nvim-baseline-checkhealth.txt
```

Si absent, chercher dans les plugins installés:
```bash
grep -rn "vim.tbl_flatten" ~/.local/share/nvim/lazy/ 2>/dev/null | grep -v "\.git/" | head -20
```

Expected: liste des plugins coupables. Noter pour Task 6.

- [ ] **Step 4: Commit baseline (les docs du plan sont déjà stagés)**

Run:
```bash
cd ~/.dotfiles && git commit -m "docs(nvim): migration 0.12 spec + plan"
```

Expected: commit créé.

---

### Task 2: Drop plugins obsolètes

**Files:**
- Delete (source): 6 fichiers dans `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/`
- Delete (target): 6 fichiers dans `~/.config/nvim/lua/knth/plugins/` (chezmoi ne propage pas les suppressions)

- [ ] **Step 1: Supprimer les fichiers plugin source**

Run:
```bash
cd ~/.dotfiles/home/dot_config/nvim/lua/knth/plugins
rm comment.lua cellular-automaton.lua undotree.lua vista.lua ufo.lua oil-nvim.lua
```

Expected: 6 fichiers supprimés.

- [ ] **Step 2: Supprimer les fichiers plugin target (chezmoi ne le fait pas)**

Run:
```bash
cd ~/.config/nvim/lua/knth/plugins
rm comment.lua cellular-automaton.lua undotree.lua vista.lua ufo.lua oil-nvim.lua
```

Expected: 6 fichiers supprimés aussi du target.

- [ ] **Step 3: Chercher des références résiduelles**

Run:
```bash
cd ~/.dotfiles/home/dot_config/nvim
grep -rn "require.*oil\|require.*ufo\|require.*undotree\|require.*vista\|require.*cellular\|Comment\\.nvim\|numToStr" lua/ --include="*.lua"
```

Expected: aucun match. Si mappings ou configs référencent ces plugins, retirer manuellement. Check probable dans `lua/knth/mappings.lua` et `lua/knth/plugins/which-keys.lua`.

- [ ] **Step 4: Nettoyer les mappings orphelins (si trouvés à Step 3)**

Retirer les lignes référençant les plugins supprimés. Patterns typiques:
```lua
-- keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>")
-- keymap.set("n", "<leader>v", "<cmd>Vista<CR>")
-- keymap.set("n", "-", "<cmd>Oil<CR>")
```

Si modifs ici, re-sync: `chezmoi apply`.

- [ ] **Step 5: Lazy purge les plugins désinstallés**

Run:
```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -20
```

Expected: Lazy désinstalle les plugins dont les fichiers sont supprimés. Pas d'erreur.

- [ ] **Step 6: Checkpoint nvim démarre sans erreur**

Run:
```bash
nvim "+qa"
```

Expected: pas de notification d'erreur.

- [ ] **Step 7: Commit**

Run:
```bash
cd ~/.dotfiles && git add -A && git commit -m "nvim: drop obsolete plugins (Comment, cellular-automaton, undotree, vista, ufo, oil)"
```

Expected: commit créé avec les suppressions + lazy-lock updated.

---

### Task 3: Fix `vim.diagnostic.config` dans options.lua

**Files:**
- Modify (source): `~/.dotfiles/home/dot_config/nvim/lua/knth/options.lua`

- [ ] **Step 1: Fix la valeur de `source`**

Dans `~/.dotfiles/home/dot_config/nvim/lua/knth/options.lua`, trouver:
```lua
vim.diagnostic.config({
	virtual_text = true,
	float = {
		source = "always",
		border = "rounded",
	},
})
```

Remplacer par:
```lua
vim.diagnostic.config({
	virtual_text = true,
	float = {
		source = true,
		border = "rounded",
	},
})
```

- [ ] **Step 2: Apply chezmoi**

Run:
```bash
chezmoi apply
```

Expected: `~/.config/nvim/lua/knth/options.lua` mis à jour.

- [ ] **Step 3: Checkpoint — pas de warning de type**

Run:
```bash
nvim --headless "+lua vim.diagnostic.config({float={source=true}})" "+qa" 2>&1
```

Expected: exit code 0, aucune sortie (pas de deprecation).

- [ ] **Step 4: Commit**

Run:
```bash
cd ~/.dotfiles && git add -A && git commit -m "nvim(options): fix vim.diagnostic.config source (string -> bool)"
```

---

### Task 4: Rewrite treesitter.lua pour API main branch

**Files:**
- Modify (source): `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/treesitter.lua`

**Contexte:** La branche `main` de nvim-treesitter a abandonné `require("nvim-treesitter.configs").setup(...)`. Nouvelle API: `require("nvim-treesitter").install(...)` + autocmd pour `vim.treesitter.start()`. `autotag` retiré (pas installé de toute façon).

- [ ] **Step 1: Remplacer le premier plugin block (nvim-treesitter)**

Dans `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/treesitter.lua`, remplacer le bloc `{ "nvim-treesitter/nvim-treesitter", ... }` (du début jusqu'à `dependencies = {},` inclus, la VIRGULE finale incluse) par:

```lua
{
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = function()
		require("nvim-treesitter").update()
	end,

	config = function()
		local parsers = {
			"rust",
			"javascript",
			"typescript",
			"html",
			"css",
			"lua",
			"json",
			"tsx",
			"yaml",
			"markdown",
			"svelte",
			"graphql",
			"bash",
			"vim",
			"dockerfile",
			"gitignore",
			"markdown_inline",
			"regex",
		}

		require("nvim-treesitter").install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local ft = args.match
				local lang = vim.treesitter.language.get_lang(ft)
				if not lang then return end

				local ok = pcall(vim.treesitter.start, args.buf, lang)
				if not ok then return end

				-- Indent treesitter (skip yaml, comme avant)
				if ft ~= "yaml" then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
},
```

Garder le second bloc (`nvim-treesitter-context`) tel quel — plugin séparé, API inchangée.

- [ ] **Step 2: Apply chezmoi**

Run:
```bash
chezmoi apply
```

- [ ] **Step 3: Lazy sync pour installer la nouvelle version**

Run:
```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -30
```

Expected: pas d'erreur. Les parsers vont être réinstallés automatiquement.

- [ ] **Step 4: Vérifier highlight sur un fichier lua**

Run:
```bash
nvim ~/.config/nvim/lua/knth/options.lua +'lua vim.defer_fn(function() print(vim.treesitter.highlighter.active[0] and "TS_ACTIVE" or "TS_INACTIVE"); vim.cmd("qa") end, 1500)'
```

Expected: output contient `TS_ACTIVE`. Si `TS_INACTIVE`, vérifier que les parsers sont installés (`:checkhealth vim.treesitter`).

- [ ] **Step 5: Commit**

Run:
```bash
cd ~/.dotfiles && git add -A && git commit -m "nvim(treesitter): rewrite for main branch API"
```

---

### Task 5: Refactor LSP — retirer nvim-lspconfig et mason-lspconfig

**Files:**
- Create (source): `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/lsp/lsp.lua`
- Delete (source): `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/lsp/lspconfig.lua`
- Delete (target): `~/.config/nvim/lua/knth/plugins/lsp/lspconfig.lua`

**Contexte:** 0.12 embarque les configs LSP dans `runtimepath/lsp/*.lua`. `vim.lsp.enable("server")` suffit. La nouvelle `lsp.lua` garde les overrides custom (denols root_dir, vtsls settings, etc.) + mason (install binaires) + fidget (UI progress).

- [ ] **Step 1: Créer le nouveau fichier lsp.lua**

Créer `~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/lsp/lsp.lua` avec:

```lua
return {
	"saghen/blink.cmp",

	dependencies = {
		{ "mason-org/mason.nvim", config = true },
		{ "j-hui/fidget.nvim", opts = {} },
	},

	config = function()
		require("mason").setup()

		-- User commands pour remplacer LspInfo/LspRestart/LspLog supprimés en 0.12
		vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {})
		vim.api.nvim_create_user_command("LspRestart", function()
			for _, client in ipairs(vim.lsp.get_clients()) do
				client:stop()
			end
			vim.defer_fn(function() vim.cmd("edit") end, 500)
		end, {})
		vim.api.nvim_create_user_command("LspLog", function()
			vim.cmd("edit " .. vim.lsp.get_log_path())
		end, {})

		-- Mappings LSP via LspAttach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("knth-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Natifs 0.12 déjà présents: K (hover), grn (rename), gra (code action),
				-- grr (references), gri (implementation), gO (document symbols).
				-- On garde uniquement les customs utilisateur:
				map("gl", vim.diagnostic.open_float, "Show line diagnostics")
				map("gK", vim.lsp.buf.signature_help, "Show signature help")
			end,
		})

		local blink_cmp_capabilities = require("blink.cmp").get_lsp_capabilities({})
		local folding_capabilities = {
			textDocument = {
				foldingRange = {
					dynamicRegistration = false,
					lineFoldingOnly = true,
				},
			},
		}

		local function is_deno_project(bufnr_or_filename)
			local root = vim.fs.root(bufnr_or_filename, { "deno.json", "deno.jsonc" })
			return root ~= nil
		end

		local effect_ls_path = vim.fn.getcwd() .. "/node_modules/@effect/language-service/"
		local has_effect_ls = vim.fn.isdirectory(effect_ls_path) == 1

		local servers = {
			html = {},
			cssls = {},
			tailwindcss = {},
			rnix = {},
			astro = {},
			jsonls = require("knth.lsp_settings.jsonls"),

			denols = {
				root_dir = function(bufnr, on_dir)
					if is_deno_project(bufnr) then on_dir() end
				end,
				single_file_support = false,
			},

			vtsls = {
				root_dir = function(bufnr, on_dir)
					if not is_deno_project(bufnr) then on_dir() end
				end,
				single_file_support = false,
				on_init = function(client)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentFormattingRangeProvider = false
				end,
				settings = {
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
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "literals",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = false,
							includeInlayVariableTypeHints = false,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = false,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "literals",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayVariableTypeHints = false,
							includeInlayFunctionParameterTypeHints = false,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = false,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
			},

			emmet_ls = {
				filetypes = {
					"html", "typescriptreact", "javascriptreact",
					"css", "sass", "scss", "less", "svelte",
				},
			},

			graphql = {
				filetypes = {
					"graphql", "gql", "svelte", "typescriptreact", "javascriptreact",
				},
			},

			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
					},
				},
			},
		}

		for server_name, server_config in pairs(servers) do
			server_config.capabilities = vim.tbl_deep_extend(
				"force",
				{},
				blink_cmp_capabilities,
				folding_capabilities,
				server_config.capabilities or {}
			)
			vim.lsp.config(server_name, server_config)
			vim.lsp.enable(server_name)
		end

		-- Signs diagnostics
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		local text_signs = {}
		local text_highlights = {}
		for type, icon in pairs(signs) do
			local severity = vim.diagnostic.severity[type:upper()]
			if severity then
				text_signs[severity] = icon
				text_highlights[severity] = "DiagnosticSign" .. type
			end
		end

		vim.diagnostic.config({
			signs = {
				text = text_signs,
				texthl = text_highlights,
				numhl = {},
			},
		})
	end,
}
```

- [ ] **Step 2: Supprimer l'ancien lspconfig.lua (source + target)**

Run:
```bash
rm ~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/lsp/lspconfig.lua
rm ~/.config/nvim/lua/knth/plugins/lsp/lspconfig.lua
```

Expected: fichiers supprimés. Vérifier: `ls ~/.dotfiles/home/dot_config/nvim/lua/knth/plugins/lsp/` montre `conform.lua`, `lazydev.lua`, `lsp.lua`, `nvim-lint.lua`.

- [ ] **Step 3: Apply chezmoi**

Run:
```bash
chezmoi apply
```

Expected: `~/.config/nvim/lua/knth/plugins/lsp/lsp.lua` créé.

- [ ] **Step 4: Lazy sync pour désinstaller les plugins retirés**

Run:
```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -20
```

Expected: Lazy désinstalle `nvim-lspconfig`, `mason-lspconfig.nvim`, `nvim-lsp-file-operations`. Pas d'erreur.

- [ ] **Step 5: Checkpoint — LSP attach sur TypeScript**

Créer un fichier test:
```bash
mkdir -p /tmp/nvim-test && cat > /tmp/nvim-test/test.ts <<'EOF'
const x: number = 42;
console.log(x);
EOF
```

Run:
```bash
nvim /tmp/nvim-test/test.ts +'lua vim.defer_fn(function() local c = vim.lsp.get_clients({bufnr=0}); print(#c > 0 and "LSP_OK:" .. c[1].name or "LSP_NONE"); vim.cmd("qa") end, 3000)'
```

Expected: output contient `LSP_OK:vtsls`. Si `LSP_NONE`, vtsls n'est peut-être pas installé via Mason — check: `:Mason` et installer si absent.

- [ ] **Step 6: Checkpoint — LSP attach sur Lua**

Run:
```bash
nvim ~/.config/nvim/init.lua +'lua vim.defer_fn(function() local c = vim.lsp.get_clients({bufnr=0}); print(#c > 0 and "LSP_OK:" .. c[1].name or "LSP_NONE"); vim.cmd("qa") end, 3000)'
```

Expected: `LSP_OK:lua_ls`.

- [ ] **Step 7: Commit**

Run:
```bash
cd ~/.dotfiles && git add -A && git commit -m "nvim(lsp): refactor to native vim.lsp.config, drop nvim-lspconfig + mason-lspconfig"
```

---

### Task 6: Résoudre deprecation `vim.tbl_flatten`

**Files:** potentiellement un plugin (identifié en Task 1).

- [ ] **Step 1: Relecture des candidats**

Depuis Task 1 Step 3, identifier les plugins qui utilisent `vim.tbl_flatten`.

- [ ] **Step 2: Mise à jour des plugins**

Run:
```bash
nvim +'Lazy update' +qa 2>&1 | tail -10
```

Puis re-check:
```bash
grep -rn "vim.tbl_flatten" ~/.local/share/nvim/lazy/ 2>/dev/null | grep -v "\.git/" | head
```

Si vide → résolu. Skip steps 3-4.

- [ ] **Step 3: Si persistant — patch local ou replace**

Si un plugin abandonné persiste:
- Option A: fork + patch pour remplacer `vim.tbl_flatten(t)` par `vim.iter(t):flatten():totable()`
- Option B: plugin de remplacement maintenu
- Option C: pin sur commit ancien (temporaire)

Documenter la décision dans un commentaire sur le plugin concerné dans la config lazy.

- [ ] **Step 4: Checkpoint — plus de warning**

Run:
```bash
nvim --headless "+checkhealth vim.deprecated" "+w /tmp/nvim-deprecated-after.txt" "+qa"
grep -i "tbl_flatten" /tmp/nvim-deprecated-after.txt
```

Expected: grep vide.

- [ ] **Step 5: Commit (si changes)**

Run:
```bash
cd ~/.dotfiles && git add -A && git commit -m "nvim: resolve vim.tbl_flatten deprecation"
```

---

### Task 7: Vérification finale

**Files:** aucun (verification only)

- [ ] **Step 1: Capture état final**

Run:
```bash
nvim --headless "+checkhealth" "+w /tmp/nvim-final-checkhealth.txt" "+qa"
diff /tmp/nvim-baseline-checkhealth.txt /tmp/nvim-final-checkhealth.txt | head -100
```

- [ ] **Step 2: Check manuel**

Ouvrir nvim et vérifier:
1. `:checkhealth` — `vim.lsp`, `vim.treesitter`, `vim.deprecated` propres
2. Ouvrir un fichier TypeScript — LSP attach, `K` (hover), completion blink
3. Ouvrir un fichier Lua — lua_ls attach, completion
4. `:LspInfo` → ouvre checkhealth vim.lsp
5. `:LspRestart` → fonctionne
6. Treesitter highlight visible
7. Mappings quotidiens intacts (`<leader>w`, `<S-l>`/`<S-h>`, etc.)

- [ ] **Step 3: Compare startup time**

Run:
```bash
nvim +'Lazy profile' +qa 2>&1 | tail -20
```

Note le total. Gain attendu (moins de plugins).

- [ ] **Step 4: Documenter notes post-migration**

Créer `~/.dotfiles/home/dot_config/nvim/docs/superpowers/plans/2026-04-16-nvim-012-migration-notes.md`:

```markdown
# Notes post-migration

## logsitter.nvim
Statut: [conservé / remplacé / supprimé]
Raison: [à remplir]

## Prochaines étapes recommandées
- [ ] Arbitrage snacks.nvim vs mini.nvim (overlap important à résoudre)
- [ ] Arbitrage telescope vs snacks.picker
- [ ] Review des autres deprecations trouvées dans la baseline
```

- [ ] **Step 5: Merge branch (quand confiance établie)**

**Ne pas faire immédiatement.** Attendre quelques jours d'usage. Puis:
```bash
cd ~/.dotfiles
git checkout main
git merge migration/nvim-0.12
git push
```

---

## Notes pour l'implémenteur

- **Source of truth:** `~/.dotfiles/home/dot_config/nvim/...` (jamais éditer `~/.config/nvim/` directement sauf pour les suppressions que chezmoi ne propage pas)
- **Workflow par étape:** edit source → `chezmoi apply` → test → commit
- **Ordre critique:** Task 1 → 2 → 3 → 4 → 5 → 6 → 7
- **Rollback:** `cd ~/.dotfiles && git reset --hard HEAD~1 && chezmoi apply`
- **Mason installe les LSPs** — la première fois que tu ouvres un fichier, Mason peut devoir installer le binaire. `:Mason` pour vérifier.
