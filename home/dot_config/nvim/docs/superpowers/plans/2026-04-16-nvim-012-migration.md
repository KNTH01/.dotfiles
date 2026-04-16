# Neovim 0.12 Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrer la config Neovim de 0.11 vers 0.12 (approche B+): fixer deprecations, retirer nvim-lspconfig/mason-lspconfig, rewrite treesitter pour la nouvelle API main, dropper les plugins obsolètes.

**Architecture:** Modifications ciblées sur lazy.nvim config existante. Keep: lazy.nvim, blink.cmp, mason. Drop: nvim-lspconfig, mason-lspconfig, nvim-lsp-file-operations + 6 plugins obsolètes (Comment, cellular-automaton, undotree, vista, ufo, oil). Refactor: lspconfig.lua → lsp.lua utilisant `vim.lsp.config()` natif. Rewrite: treesitter.lua pour API main branch.

**Tech Stack:** Neovim 0.12, Lua, lazy.nvim, blink.cmp, mason.nvim, nvim-treesitter (branch main), vtsls/denols/lua_ls/etc. LSPs.

---

## File Structure

**Files à créer:**
- `lua/knth/plugins/lsp/lsp.lua` — nouvelle config LSP native (remplace lspconfig.lua)

**Files à modifier:**
- `lua/knth/options.lua` — `vim.diagnostic.config` fix
- `lua/knth/plugins/treesitter.lua` — rewrite pour API main branch

**Files à supprimer:**
- `lua/knth/plugins/lsp/lspconfig.lua` (remplacé par lsp.lua)
- `lua/knth/plugins/comment.lua`
- `lua/knth/plugins/cellular-automaton.lua`
- `lua/knth/plugins/undotree.lua`
- `lua/knth/plugins/vista.lua`
- `lua/knth/plugins/ufo.lua`
- `lua/knth/plugins/oil-nvim.lua`

**Note:** Ce projet n'est pas un git repo. On utilise un backup dossier pour rollback. "Commit" dans ce plan = checkpoint via verify que nvim démarre OK.

---

### Task 1: Baseline + Backup

**Files:**
- Create: `~/.config/nvim.bak-2026-04-16/` (backup)
- Create: `/tmp/nvim-baseline-checkhealth.txt` (diagnostic baseline)

- [ ] **Step 1: Backup complet du dossier**

Run:
```bash
cp -r ~/.config/nvim ~/.config/nvim.bak-2026-04-16
```

Expected: dossier `~/.config/nvim.bak-2026-04-16/` créé, `ls ~/.config/nvim.bak-2026-04-16/` montre init.lua, lua/, etc.

- [ ] **Step 2: Capture baseline checkhealth**

Run:
```bash
nvim --headless "+checkhealth" "+w /tmp/nvim-baseline-checkhealth.txt" "+qa" 2>&1 | tee /tmp/nvim-baseline-startup.txt
```

Expected: fichier `/tmp/nvim-baseline-checkhealth.txt` créé. Contient le rapport checkhealth complet (notamment sections `vim.deprecated`, `vim.lsp`, `vim.treesitter`).

- [ ] **Step 3: Identifier la source de `vim.tbl_flatten`**

Run:
```bash
grep -n "tbl_flatten" /tmp/nvim-baseline-checkhealth.txt
```

Si pas trouvé dans checkhealth, chercher dans les plugins installés:
```bash
grep -rn "vim.tbl_flatten" ~/.local/share/nvim/lazy/ 2>/dev/null | grep -v "\.git/" | head -20
```

Expected: liste des fichiers plugin appelant `vim.tbl_flatten`. Noter les plugins coupables pour Task 9.

- [ ] **Step 4: Checkpoint — nvim démarre OK**

Run: `nvim --headless "+echo 'ok'" "+qa"`
Expected: exit code 0, output "ok".

---

### Task 2: Drop plugins obsolètes

**Files:**
- Delete: `lua/knth/plugins/comment.lua`
- Delete: `lua/knth/plugins/cellular-automaton.lua`
- Delete: `lua/knth/plugins/undotree.lua`
- Delete: `lua/knth/plugins/vista.lua`
- Delete: `lua/knth/plugins/ufo.lua`
- Delete: `lua/knth/plugins/oil-nvim.lua`

- [ ] **Step 1: Supprimer les fichiers plugin**

Run:
```bash
cd ~/.config/nvim
rm lua/knth/plugins/comment.lua
rm lua/knth/plugins/cellular-automaton.lua
rm lua/knth/plugins/undotree.lua
rm lua/knth/plugins/vista.lua
rm lua/knth/plugins/ufo.lua
rm lua/knth/plugins/oil-nvim.lua
```

Expected: 6 fichiers supprimés. Vérifier: `ls lua/knth/plugins/ | wc -l` diminué de 6.

- [ ] **Step 2: Chercher des références résiduelles**

Run:
```bash
cd ~/.config/nvim
grep -rn "require.*oil\|require.*ufo\|require.*undotree\|require.*vista\|require.*cellular\|Comment\\.nvim\|numToStr" lua/ --include="*.lua"
```

Expected: aucun match. Si des mappings ou configs référencent ces plugins, les retirer manuellement. Candidats probables: mappings custom pour `:UndotreeToggle`, `:Vista`, `:Oil`. Check `lua/knth/mappings.lua` et `lua/knth/plugins/which-keys.lua`.

- [ ] **Step 3: Nettoyer les mappings orphelins (si trouvés à Step 2)**

Ouvrir les fichiers identifiés et retirer les lignes qui mappent vers les plugins supprimés. Exemple de pattern à chercher:
```lua
-- À retirer si présent:
-- keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>")
-- keymap.set("n", "<leader>v", "<cmd>Vista<CR>")
-- keymap.set("n", "-", "<cmd>Oil<CR>")
```

- [ ] **Step 4: Checkpoint — nvim démarre et Lazy purge les plugins**

Run:
```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -20
```

Expected: pas d'erreur. Lazy désinstalle les plugins supprimés. Si erreur "module not found" pour un des plugins, c'est qu'il reste une référence — retour à Step 2/3.

Run ensuite:
```bash
nvim "+qa"
```

Expected: pas de notification d'erreur au démarrage.

---

### Task 3: Fix `vim.diagnostic.config` dans options.lua

**Files:**
- Modify: `lua/knth/options.lua` (ligne du bloc `vim.diagnostic.config`)

- [ ] **Step 1: Fix la valeur de `source`**

Dans `lua/knth/options.lua`, trouver:
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

- [ ] **Step 2: Checkpoint — pas de warning de type**

Run:
```bash
nvim --headless "+lua vim.diagnostic.config({float={source=true}})" "+qa" 2>&1
```

Expected: exit code 0, aucune sortie (pas de deprecation).

---

### Task 4: Rewrite treesitter.lua pour API main branch

**Files:**
- Modify: `lua/knth/plugins/treesitter.lua` (rewrite complet du premier bloc)

**Contexte:** La branche `main` de nvim-treesitter a abandonné `require("nvim-treesitter.configs").setup(...)`. La nouvelle API expose `require("nvim-treesitter").install(...)` et nécessite d'appeler `vim.treesitter.start()` via autocmd. `autotag` n'est plus intégré (nécessiterait `nvim-ts-autotag` séparé — NOT installed dans lazy-lock donc était déjà no-op).

- [ ] **Step 1: Remplacer le premier plugin block (nvim-treesitter)**

Dans `lua/knth/plugins/treesitter.lua`, remplacer le bloc `{ "nvim-treesitter/nvim-treesitter", ... }` (du début jusqu'à `dependencies = {},` inclus) par:

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

		-- Map parser names to filetypes for FileType autocmd
		local ft_to_parser = vim.treesitter.language.get_filetypes or function() return {} end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local ft = args.match
				local lang = vim.treesitter.language.get_lang(ft)
				if not lang then return end

				-- Start treesitter highlighting
				local ok = pcall(vim.treesitter.start, args.buf, lang)
				if not ok then return end

				-- Enable treesitter-based indentation (skip yaml, user preference from old config)
				if ft ~= "yaml" then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
},
```

Garder le second bloc (`nvim-treesitter/nvim-treesitter-context`) tel quel — ce plugin est séparé et son API n'a pas changé.

- [ ] **Step 2: Checkpoint — parsers installés et highlight actif**

Run:
```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -30
```

Expected: pas d'erreur. `nvim-treesitter` s'installe sans crash.

Ensuite:
```bash
nvim +TSUpdate +qa 2>&1 | tail -5
```

Note: si `:TSUpdate` n'existe plus, la commande native est `:TSInstall` ou via `require("nvim-treesitter").update()`. Les parsers se télécharger automatiquement au premier lancement.

- [ ] **Step 3: Vérifier highlight sur un fichier lua**

Run:
```bash
nvim lua/knth/options.lua +'lua vim.defer_fn(function() print(vim.treesitter.highlighter.active[0] and "TS_ACTIVE" or "TS_INACTIVE"); vim.cmd("qa") end, 500)'
```

Expected: output contient `TS_ACTIVE`. Si `TS_INACTIVE`, vérifier que `vim.treesitter.start()` a bien été appelé dans l'autocmd.

---

### Task 5: Refactor LSP — retirer nvim-lspconfig et mason-lspconfig

**Files:**
- Create: `lua/knth/plugins/lsp/lsp.lua`
- Delete: `lua/knth/plugins/lsp/lspconfig.lua`

**Contexte:** Neovim 0.12 embarque les configs LSP par défaut dans `runtimepath/lsp/*.lua`. On peut donc `vim.lsp.enable("server")` sans avoir `nvim-lspconfig`. La nouvelle `lsp.lua` garde juste les overrides custom de l'utilisateur (denols root_dir, vtsls settings, etc.).

- [ ] **Step 1: Créer le nouveau fichier lsp.lua**

Créer `lua/knth/plugins/lsp/lsp.lua` avec le contenu:

```lua
return {
	-- Blink.cmp fournit les capabilities, mason les binaires, fidget l'UI.
	-- Plus besoin de nvim-lspconfig (0.12 ship les configs nativement).
	"saghen/blink.cmp",

	dependencies = {
		{ "mason-org/mason.nvim", config = true },
		{ "j-hui/fidget.nvim", opts = {} },
	},

	config = function()
		-- Setup Mason (install binaires des LSPs)
		require("mason").setup()

		-- User commands pour remplacer LspInfo/LspRestart/LspLog supprimés
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

				-- K (hover), grn (rename), gra (code action), grr (references), gri (implementation), gO (symbols)
				-- sont maintenant des defaults natifs de Neovim 0.12 — pas besoin de les remap.
				-- On garde uniquement les customs utilisateur qui ne sont pas couverts:
				map("gl", vim.diagnostic.open_float, "Show line diagnostics")
				map("gK", vim.lsp.buf.signature_help, "Show signature help")
			end,
		})

		-- Capabilities combinées (blink.cmp + folding)
		local blink_cmp_capabilities = require("blink.cmp").get_lsp_capabilities({})
		local folding_capabilities = {
			textDocument = {
				foldingRange = {
					dynamicRegistration = false,
					lineFoldingOnly = true,
				},
			},
		}

		-- Helper: détection projet Deno
		local function is_deno_project(bufnr_or_filename)
			local root = vim.fs.root(bufnr_or_filename, { "deno.json", "deno.jsonc" })
			return root ~= nil
		end

		-- Effect language service (optionnel)
		local effect_ls_path = vim.fn.getcwd() .. "/node_modules/@effect/language-service/"
		local has_effect_ls = vim.fn.isdirectory(effect_ls_path) == 1

		-- Définitions des overrides par serveur
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

		-- Appliquer chaque serveur: merge capabilities + enable
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

		-- Signs diagnostics dans la gutter
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

- [ ] **Step 2: Supprimer l'ancien lspconfig.lua**

Run:
```bash
rm ~/.config/nvim/lua/knth/plugins/lsp/lspconfig.lua
```

Expected: fichier supprimé. Vérifier: `ls ~/.config/nvim/lua/knth/plugins/lsp/` montre `conform.lua`, `lazydev.lua`, `lsp.lua`, `nvim-lint.lua` (4 fichiers).

- [ ] **Step 3: Vérifier lazy.nvim pick up le rename**

Le fichier `lua/knth/lazy.lua` utilise `{ import = "knth.plugins.lsp" }` qui importe tout le dossier. Aucun changement requis.

Run:
```bash
nvim --headless "+Lazy! sync" "+qa" 2>&1 | tail -20
```

Expected: lazy désinstalle `nvim-lspconfig`, `mason-lspconfig.nvim`, `nvim-lsp-file-operations`. Pas d'erreur.

- [ ] **Step 4: Checkpoint — LSP attach fonctionne sur TypeScript**

Créer un fichier test temporaire:
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

Expected: output contient `LSP_OK:vtsls` (ou `LSP_OK:denols` si tu es dans un projet Deno). Si `LSP_NONE`, vtsls n'est peut-être pas installé. Check: `nvim +'Mason' +qa` puis vérifier manuellement.

- [ ] **Step 5: Checkpoint — LSP attach fonctionne sur Lua**

Run:
```bash
nvim ~/.config/nvim/init.lua +'lua vim.defer_fn(function() local c = vim.lsp.get_clients({bufnr=0}); print(#c > 0 and "LSP_OK:" .. c[1].name or "LSP_NONE"); vim.cmd("qa") end, 3000)'
```

Expected: output contient `LSP_OK:lua_ls`.

---

### Task 6: Résoudre deprecation `vim.tbl_flatten`

**Files:**
- Potentiellement: modifier un plugin ou le replacer. Dépend du coupable identifié en Task 1 Step 3.

**Contexte:** `vim.tbl_flatten` est deprecated en 0.12, remplacé par `vim.iter(...):flatten():totable()`. Le code utilisateur n'en contient pas, donc vient d'un plugin.

- [ ] **Step 1: Relecture des candidats identifiés en Task 1**

Depuis l'output de Task 1 Step 3, identifier les plugins qui utilisent `vim.tbl_flatten`. Candidats probables: plugins sur branch `master` pas maintenus, ou versions pinnées anciennes.

- [ ] **Step 2: Mise à jour des plugins**

Run:
```bash
nvim +'Lazy update' +qa 2>&1 | tail -10
```

Expected: Lazy bump les commits. Re-check si `vim.tbl_flatten` est encore utilisé:
```bash
grep -rn "vim.tbl_flatten" ~/.local/share/nvim/lazy/ 2>/dev/null | grep -v "\.git/" | head
```

Si vide → problème résolu par l'update.

- [ ] **Step 3: Si persistant, patch local ou replace**

Si un plugin abandonné persiste à utiliser `vim.tbl_flatten`:
- Option A: fork + patch
- Option B: remplacer par un équivalent maintenu
- Option C: pin sur un commit qui n'a pas encore l'appel (temporaire)

Décision à prendre au cas par cas selon le plugin identifié. Documenter dans un commentaire dans la config du plugin concerné.

- [ ] **Step 4: Checkpoint — plus de deprecation warning**

Run:
```bash
nvim --headless "+checkhealth vim.deprecated" "+w /tmp/nvim-deprecated-after.txt" "+qa"
grep -i "tbl_flatten" /tmp/nvim-deprecated-after.txt
```

Expected: grep retourne vide (pas de match).

---

### Task 7: Vérification finale

**Files:** aucun (verification only)

- [ ] **Step 1: Capture état final**

Run:
```bash
nvim --headless "+checkhealth" "+w /tmp/nvim-final-checkhealth.txt" "+qa"
```

Expected: fichier créé. Comparer avec `/tmp/nvim-baseline-checkhealth.txt`:

```bash
diff /tmp/nvim-baseline-checkhealth.txt /tmp/nvim-final-checkhealth.txt | head -100
```

- [ ] **Step 2: Vérifier critères de succès**

Check manuel en ouvrant nvim:

1. `:checkhealth` — section `vim.lsp` OK, section `vim.treesitter` OK, section `vim.deprecated` sans warnings actifs
2. Ouvrir un fichier TypeScript → LSP attach, hover (`K`), completion blink
3. Ouvrir un fichier Lua → lua_ls attach, completion
4. `:LspInfo` → ouvre checkhealth vim.lsp
5. `:LspRestart` → fonctionne sans erreur
6. Treesitter highlight visible (couleurs de syntaxe correctes)
7. Mappings quotidiens intacts (`<leader>w`, `<S-l>`/`<S-h>` buffers, etc.)

- [ ] **Step 3: Comparer startup time**

Run:
```bash
nvim +'Lazy profile' +qa 2>&1 | tail -20
```

Note le total startup time. Comparer avec ton habitude avant migration. Un gain est attendu (moins de plugins chargés).

- [ ] **Step 4: Documenter les décisions ouvertes restantes**

Créer une note dans `docs/superpowers/plans/2026-04-16-nvim-012-migration-notes.md`:

```markdown
# Notes post-migration

## logsitter.nvim
Statut: [conservé / remplacé / supprimé]
Raison: [à remplir]

## Prochaines étapes recommandées
- [ ] Initialiser git repo dans ~/.config/nvim pour versioning
- [ ] Arbitrage snacks.nvim vs mini.nvim (overlap important à résoudre)
- [ ] Arbitrage telescope vs snacks.picker
```

- [ ] **Step 5: Nettoyage backup (optionnel)**

Une fois que la config tourne depuis quelques jours sans problème:
```bash
rm -rf ~/.config/nvim.bak-2026-04-16
```

Ne pas exécuter tant que la confiance n'est pas établie (attendre une semaine d'usage minimum).

---

## Notes pour l'implémenteur

- **Ordre critique:** Task 1 (baseline) → Task 2 (drop) → Tasks 3-4 (simples fixes) → Task 5 (gros refactor LSP) → Task 6 (cleanup deprecation). Task 7 = verification.
- **Rollback:** à n'importe quel moment, `rm -rf ~/.config/nvim && cp -r ~/.config/nvim.bak-2026-04-16 ~/.config/nvim`.
- **Pas de tests automatisés** — toutes les vérifications sont manuelles ou headless nvim commands.
- **Mason installe les LSPs** — la première fois que tu ouvres un fichier, Mason peut avoir besoin d'installer le binaire LSP si absent. Vérifier via `:Mason`.
