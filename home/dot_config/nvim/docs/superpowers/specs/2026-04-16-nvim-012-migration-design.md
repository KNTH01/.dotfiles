# Migration config Neovim 0.11 → 0.12

**Date:** 2026-04-16
**Status:** Design validé, en attente de review utilisateur

## Objectif

Aligner la config Neovim avec la release 0.12:
- Fixer les deprecations et APIs cassées
- Retirer les dépendances devenues redondantes avec le core
- Auditer et drop les plugins obsolètes
- Adopter les conventions 0.12 pertinentes sans casser le confort quotidien

Approche choisie: **B+** — pragmatique. On garde lazy.nvim, blink.cmp, mason (sans mason-lspconfig). On vire nvim-lspconfig (redondant avec `vim.lsp.config()` natif en 0.12). On profite du passage pour un audit plugin léger.

## Non-objectifs

- Migration vers `vim.pack` (lazy.nvim reste supérieur en features)
- Remplacement de blink.cmp par la completion native (blink reste supérieur)
- Activation de UI2 (encore expérimental)
- Arbitrage snacks.nvim vs mini.nvim (reporté post-migration)
- Setup de tests automatisés

## Scope

### 1. Deprecations et APIs cassées

**1.1 `vim.tbl_flatten`** — deprecation affichée au démarrage. Source inconnue (pas dans le code utilisateur). À identifier via `:checkhealth vim.deprecated` pendant l'exécution, puis:
- Si plugin maintenu: mise à jour
- Si plugin abandonné: patch local ou remplacement

**1.2 Treesitter — branch `main`**
La config actuelle utilise `nvim-treesitter.configs.setup({...})` qui n'existe plus sur la branche `main`. Rewrite requis:
```lua
-- Nouvelle API (main branch)
require("nvim-treesitter").install({ "rust", "javascript", ... })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { ... },
  callback = function() vim.treesitter.start() end,
})
```
Plus de table `highlight`/`indent`/`ensure_installed` dans un setup monolithique.

**1.3 `vim.diagnostic.config` — `source = "always"`**
Dans `lua/knth/options.lua`:
```lua
float = {
  source = "always",  -- → source = true (nouveau type bool)
  border = "rounded",
},
```

### 2. Retrait nvim-lspconfig + mason-lspconfig

La config actuelle (`lua/knth/plugins/lsp/lspconfig.lua`) utilise déjà `vim.lsp.config()` + `vim.lsp.enable()`, donc le plugin `nvim-lspconfig` ne sert plus que de collection de presets serveur. Neovim 0.12 embarque ces presets nativement dans `runtimepath/lsp/*.lua`.

**Actions:**
- Renommer `lsp/lspconfig.lua` → `lsp/lsp.lua`
- Retirer `neovim/nvim-lspconfig` et `mason-org/mason-lspconfig.nvim` des dépendances
- Retirer `antosha417/nvim-lsp-file-operations` (rename cross-file géré nativement via `grn`)
- Garder: `mason-org/mason.nvim` (install binaires), `saghen/blink.cmp`, `j-hui/fidget.nvim`
- Les overrides custom (denols root_dir, vtsls inlay hints, etc.) restent dans `vim.lsp.config("<server>", {...})`

### 3. Commandes LSP supprimées

`LspInfo`, `LspRestart`, `LspLog` retirés en 0.12. Recréer comme user commands:
```lua
vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {})
vim.api.nvim_create_user_command("LspRestart", "lsp restart", {})
vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd("edit " .. vim.lsp.get_log_path())
end, {})
```

### 4. Mappings LSP — arbitrage

Neovim 0.12 ajoute par défaut: `K` (hover), `grn` (rename), `gra` (code action), `grr` (references), `gri` (implementation), `gO` (document symbols).

**Décision:** adopter les defaults natifs. Dans l'autocmd `LspAttach`:
- Drop `gk` custom pour hover (use native `K`)
- Drop `K` custom pour signature (conflit avec native hover). Signature help accessible via `<C-k>` blink déjà configuré, ou nouveau mapping dédié (ex: `gK`).
- Garder `gl` pour `vim.diagnostic.open_float` (pas couvert par defaults)

### 5. Audit plugins — drop

**Drop confirmés:**
- `comment.lua` (`numToStr/Comment.nvim`) — `gcc`/`gc` natif depuis 0.10
- `cellular-automaton.lua` — gimmick
- `undotree.lua` — `:Undotree` natif en 0.12
- `vista.lua` — remplacé par `trouble symbols` / pickers LSP
- `ufo.lua` — folding treesitter natif suffisant
- `oil-nvim.lua` — utilisateur utilise `mini.files` maintenant
- `nvim-lsp-file-operations` — voir section 2

**À surveiller (garder pour l'instant, flag pour review):**
- `logsitter.lua` — usage/origine à vérifier pendant l'exécution

**Reporté post-migration:**
- Arbitrage `snacks.nvim` vs `mini.nvim` (gros overlap: pickers, notif, statuscol, etc.)
- Arbitrage `telescope` vs `snacks.picker`

## Hors scope

- Migration vim.pack
- Abandon de blink.cmp
- Activation UI2
- Refactoring options.lua / mappings.lua au-delà des fixes listés
- Nouveaux plugins

## Stratégie d'exécution

### Safety net

Le répertoire `~/.config/nvim` n'est **pas** un git repo. Backup par copie avant de commencer:
```bash
cp -r ~/.config/nvim ~/.config/nvim.bak-2026-04-16
```
Rollback = restauration du dossier backup.

**Note:** à considérer d'initialiser un git repo dans `~/.config/nvim` après migration (hors scope de ce spec mais recommandé).

### Ordre d'exécution (du moins risqué au plus risqué)

1. Backup dossier
2. Baseline: `nvim`, `:checkhealth`, capturer output complet (deprecations, erreurs)
3. Drop plugins inutiles (suppression des fichiers `lua/knth/plugins/*.lua` listés en section 5)
4. Fix `options.lua` — `source = true`
5. Rewrite `treesitter.lua` pour API main branch
6. Retirer `nvim-lspconfig` + `mason-lspconfig` + `nvim-lsp-file-operations` — refactor en `lsp.lua`
7. Ajouter user commands `LspInfo`/`LspRestart`/`LspLog`
8. Arbitrer mappings LSP (adopter defaults natifs + garder `gl`)
9. Résoudre `vim.tbl_flatten` (update ou remplacer le plugin responsable)
10. Vérif finale: `:checkhealth` propre, redémarrer

### Critères de succès

- `:checkhealth` sans erreurs (warnings acceptables)
- Completion blink fonctionnelle
- LSP hover/rename/references/diagnostics OK sur TypeScript et Lua
- Treesitter highlight actif sur fichiers core
- Pas de regressions sur mappings quotidiens
- Startup time non dégradé (`:Lazy profile` comparable)

## Questions ouvertes

- `logsitter.lua` — à identifier pendant l'exécution (plugin externe ou local?)
- Source de `vim.tbl_flatten` — à identifier via `:checkhealth vim.deprecated`
