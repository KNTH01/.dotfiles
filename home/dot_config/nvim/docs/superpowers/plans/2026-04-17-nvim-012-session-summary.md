# Session summary — Migration Neovim 0.11 → 0.12

**Dates:** 2026-04-16 (brainstorm + exécution partielle) + 2026-04-17 (complétion)
**Branch:** `migration/nvim-0.12` dans `~/.dotfiles/`
**Approche:** B+ (pragmatique) — garder lazy.nvim, blink.cmp, mason; drop plugins obsolètes; adopter APIs natives 0.12 là où c'est clairement mieux.

---

## Contexte de départ

- Upgrade Neovim 0.11 → 0.12 fait côté système.
- Config non-touchée depuis longtemps. Deprecation au démarrage: `vim.tbl_flatten`.
- Config gérée par **chezmoi** (source: `~/.dotfiles/home/dot_config/nvim/`, target: `~/.config/nvim/`).

---

## Ce qui a été fait (exhaustif)

### Phase 1 — Brainstorming & design

- Exploration de la config existante (lazy.nvim, blink.cmp, nvim-lspconfig, mason, treesitter main, 32 plugins).
- Identification des deprecations 0.12 impactant la config.
- Discussion 3 approches (conservateur / pragmatique / minimaliste).
- Décision: **B+** — garder lazy/blink/mason, drop nvim-lspconfig + mason-lspconfig, audit plugins léger.
- Audit plugins: drop confirmés (Comment, cellular-automaton, undotree, vista, ufo, oil, nvim-lsp-file-operations).

**Livrables docs (committés):**
- `docs/superpowers/specs/2026-04-16-nvim-012-migration-design.md` — spec complet
- `docs/superpowers/plans/2026-04-16-nvim-012-migration.md` — plan d'exécution détaillé

### Phase 2 — Exécution (7 tasks)

**Task 1 — Baseline capture**
- `:checkhealth` → `/tmp/nvim-baseline-checkhealth.txt`
- Source deprecation `vim.tbl_flatten` identifiée: `nvim-colorizer.lua` (fork norcalli abandonné)
- Commit `8252a92` docs: migration 0.12 spec + plan

**Task 2 — Drop 6 plugins obsolètes**
- Supprimés (source + target): `comment.lua`, `cellular-automaton.lua`, `undotree.lua`, `vista.lua`, `ufo.lua`, `oil-nvim.lua`
- Bonus: cleanup `folding_capabilities` dead code dans lspconfig.lua (était pour ufo)
- Commit `1ca1997` drop obsolete plugins

**Task 3 — Fix `vim.diagnostic.config`**
- `source = "always"` → `source = true` dans `lua/knth/options.lua` (nouveau type bool en 0.12)
- Commit `f4444a0` fix diagnostic config source

**Task 4 — Treesitter rewrite pour API main branch**
- Abandonné `require("nvim-treesitter.configs").setup(...)` (n'existe plus sur branch main)
- Nouveau: `require("nvim-treesitter").install(parsers)` + autocmd FileType avec `vim.treesitter.start()`
- Indent treesitter activé (yaml skipped comme avant)
- **Nouvelle dép système installée:** `tree-sitter` CLI via `bun install -g tree-sitter-cli` (v0.26.8)
- 18 parsers compilés avec succès
- Commit `feaa0bf` treesitter main branch API

**Task 5 — Refactor LSP**
- Créé `lua/knth/plugins/lsp/lsp.lua` utilisant `vim.lsp.config()` + `vim.lsp.enable()` natifs
- Supprimé `lua/knth/plugins/lsp/lspconfig.lua` (remplacé)
- Ajoutés user commands `LspInfo`/`LspRestart`/`LspLog` (retirés en 0.12)
- Mappings natifs 0.12 adoptés: `K`, `grn`, `gra`, `grr`, `gri`, `gO`
- Customs conservés: `gl` (diagnostic float), `gK` (signature help)
- **Drop plugins:** `mason-lspconfig.nvim`, `nvim-lsp-file-operations`
- **Conservé (déviation vs spec):** `nvim-lspconfig` — voir section Déviations
- Commit `5f681c0` refactor LSP

**Task 6 — Résoudre deprecation**
- `norcalli/nvim-colorizer.lua` (abandonné) → `catgoose/nvim-colorizer.lua` (fork maintenu)
- `vim.tbl_flatten` deprecation résolue
- Commit `d900840` replace colorizer

**Task 7 — Vérification + notes**
- `:checkhealth vim.deprecated` → ✅ OK (no deprecated functions detected)
- LSP vtsls attach sur TS ✅
- LSP lua_ls attach sur Lua ✅
- Treesitter highlight actif ✅
- Commit `fc20116` post-migration notes

---

## Déviations vs spec original

### 1. `nvim-lspconfig` conservé (NON dropped comme prévu)

**Spec initial:** drop nvim-lspconfig, 0.12 ship les presets nativement.

**Réalité découverte:** Neovim 0.12 a les APIs (`vim.lsp.config`, `vim.lsp.enable`) et le mécanisme d'auto-load `lsp/*.lua` dans runtimepath, mais **ne ship PAS les presets serveur** (cmd, root_markers, filetypes). Ces 391 presets viennent toujours de nvim-lspconfig.

**Test qui a exposé le problème:** après drop initial, `vim.api.nvim_get_runtime_file('lsp/*.lua', true)` retournait `{}`. LSP_NONE sur TS et Lua.

**Résolution:** re-ajouté `nvim-lspconfig` comme dépendance de `blink.cmp` dans `lsp.lua`. C'est maintenant un simple fournisseur de presets, le code utilisateur utilise les APIs natives.

### 2. Cleanup bonus dans Task 2

L'implémenteur a détecté et supprimé `folding_capabilities` dead code dans lspconfig.lua (était référencé pour `ufo.nvim` qui venait d'être dropped). Le nouveau `lsp.lua` créé en Task 5 est donc sans ce bloc.

### 3. Colorizer remplacé par fork

Spec Task 6 donnait 3 options (update / fork-patch / replace). Choix: remplacement par fork maintenu `catgoose/nvim-colorizer.lua`.

---

## Issues rencontrées & workarounds

### `lazy-lock.json` diverge source ↔ target

`:Lazy sync` écrit sur la target (`~/.config/nvim/lazy-lock.json`). `chezmoi apply` refuse d'overwriter sans TTY avec l'erreur:
```
.config/nvim/lazy-lock.json has changed since chezmoi last wrote it?
```

**Workaround appliqué à chaque Task:**
```bash
cp ~/.config/nvim/lazy-lock.json ~/.dotfiles/home/dot_config/nvim/lazy-lock.json
chezmoi apply
```

**Amélioration possible:** configurer chezmoi pour marquer `lazy-lock.json` comme externally-managed ou utiliser un template.

### Test TS_ACTIVE du plan était buggy

Le snippet de vérif treesitter utilisait `highlighter.active[0]` (buffer alias `0`) qui ne résolvait pas dans `vim.defer_fn`. Real state `TS_ACTIVE` via `highlighter.active[current_buf]`.

---

## État final

**Critères de succès atteints:**
- ✅ `:checkhealth vim.deprecated` → OK (no deprecated functions)
- ✅ LSP attach (vtsls sur TS, lua_ls sur Lua)
- ✅ Blink completion fonctionnelle
- ✅ Treesitter highlight actif (18 parsers)
- ✅ `:LspInfo`, `:LspRestart`, `:LspLog` fonctionnent (user commands)
- ✅ Mappings quotidiens intacts

**Plugins supprimés au total (8):**
- `norcalli/Comment.nvim`
- `Eandrju/cellular-automaton.nvim`
- `mbbill/undotree`
- `liuchengxu/vista.vim`
- `kevinhwang91/nvim-ufo` + `promise-async` (dep)
- `stevearc/oil.nvim`
- `ts-comments.nvim` (dep transitive de Comment)
- `mason-org/mason-lspconfig.nvim`
- `antosha417/nvim-lsp-file-operations`

**Plugin remplacé:**
- `norcalli/nvim-colorizer.lua` → `catgoose/nvim-colorizer.lua`

**8 commits sur la branche:**
```
fc20116 docs(nvim): post-migration notes + deviations from spec
d900840 nvim: replace abandoned nvim-colorizer.lua (norcalli) with catgoose fork
5f681c0 nvim(lsp): refactor to native vim.lsp.config, drop mason-lspconfig + nvim-lsp-file-operations
feaa0bf nvim(treesitter): rewrite for main branch API
f4444a0 nvim(options): fix vim.diagnostic.config source (string -> bool)
1ca1997 nvim: drop obsolete plugins (Comment, cellular-automaton, undotree, vista, ufo, oil)
39042ce docs(nvim): update spec + plan for chezmoi workflow
8252a92 docs(nvim): migration 0.12 spec + plan
```

---

## Ce qui reste à faire

### Immédiat — avant de merger
- [ ] **Test d'usage quotidien** pendant 2-7 jours. Ouvrir des fichiers TS/Lua/Rust/Markdown, utiliser LSP (hover, rename, references), completion, telescope/snacks pickers, git workflows, etc.
- [ ] **Vérifier mappings natifs 0.12** — `K`, `grn`, `gra`, `grr`, `gri`, `gO`. Comportement conforme?
- [ ] **Merge après confiance établie:**
  ```bash
  cd ~/.dotfiles
  git checkout main
  git merge migration/nvim-0.12
  git push
  ```

### Court terme — cleanup
- [ ] **Workflow chezmoi + lazy-lock.json** — résoudre la divergence systématique. Options:
  - Ajouter `lazy-lock.json` à `.chezmoiignore`
  - Ou utiliser un template chezmoi
  - Ou workflow post-sync: `chezmoi re-add` après `:Lazy sync`
- [ ] **`tree-sitter` CLI dans tooling reproductible** — actuellement installé ad-hoc via `bun install -g tree-sitter-cli`. Ajouter au setup de machine (mise, homebrew, ou package système) pour qu'une nouvelle machine marche out-of-the-box.
- [ ] **Investiguer `logsitter.nvim`** — plugin conservé par précaution pendant la migration. Vérifier ce qu'il fait, si tu l'utilises vraiment, et le dropper sinon.

### Moyen terme — reporté post-migration (grosse décision architecturale)
- [ ] **Arbitrage `snacks.nvim` vs `mini.nvim`** — gros overlap fonctionnel (pickers, notifications, statuscolumn, indent, etc.). Tu charges les deux = duplication. Choisir l'un, drop l'autre, ou keep les deux avec clarté sur qui fait quoi.
- [ ] **Arbitrage `telescope.nvim` vs `snacks.picker`** — même logique. Si snacks reste, possiblement drop telescope.
- [ ] **Snacks.input** — l'erreur checkhealth `vim.ui.input is not set to Snacks.input` (pré-existante, pas causée par cette migration) pourrait être résolue si tu utilises snacks.

### Pas de rush — nice-to-haves
- [ ] Explorer UI2 (experimental) quand il sera stable
- [ ] Évaluer si `vim.pack` devient assez mature un jour pour replacer lazy.nvim
- [ ] Évaluer la completion native 0.12 (mais blink reste supérieur pour l'instant)

---

## Refs

- Spec: `docs/superpowers/specs/2026-04-16-nvim-012-migration-design.md`
- Plan: `docs/superpowers/plans/2026-04-16-nvim-012-migration.md`
- Notes détaillées: `docs/superpowers/plans/2026-04-17-nvim-012-migration-notes.md`
- Neovim 0.12 release notes: https://neovim.io/doc/user/news-0.12/
