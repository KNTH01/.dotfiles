# Notes post-migration Neovim 0.12

**Date:** 2026-04-17
**Branch:** `migration/nvim-0.12`

## Résultat

Migration complète et fonctionnelle. `vim.deprecated` ✅ clean. LSP attach OK (vtsls, lua_ls). Treesitter ✅ actif (18 parsers).

## Commits

- `8252a92` docs: spec + plan initial
- `39042ce` docs: update pour workflow chezmoi
- `1ca1997` Task 2: drop 6 plugins obsolètes
- `f4444a0` Task 3: fix vim.diagnostic source
- `feaa0bf` Task 4: treesitter main branch API
- `5f681c0` Task 5: refactor LSP native vim.lsp.config
- `d900840` Task 6: replace colorizer (norcalli → catgoose)

## Déviations vs spec original

### nvim-lspconfig conservé
**Spec initial:** drop nvim-lspconfig.
**Réalité:** gardé comme dépendance.
**Raison:** Neovim 0.12 a les APIs (`vim.lsp.config`, `vim.lsp.enable`) et le mécanisme d'auto-load `lsp/*.lua`, mais ne ship PAS les presets serveur (cmd, root_markers, filetypes). Ces presets viennent de nvim-lspconfig (391 fichiers). Sans ce plugin, aucun LSP ne démarre.
**Toujours dropped:** `mason-lspconfig.nvim`, `nvim-lsp-file-operations`.

### Cleanup bonus Task 2
L'implémenteur a supprimé `folding_capabilities` dead code dans lspconfig.lua (était pour ufo.nvim, dropped). Nouveau lsp.lua créé sans folding_capabilities.

### Colorizer remplacé (Task 6)
`norcalli/nvim-colorizer.lua` abandonné → switch vers `catgoose/nvim-colorizer.lua` (fork maintenu, résout `vim.tbl_flatten`).

## Workflow chezmoi — issue rencontrée

`lazy-lock.json` diverge régulièrement entre source et target (Neovim write sur target via `:Lazy sync`). `chezmoi apply` refuse d'overwriter sans TTY.

**Workaround appliqué:** avant chaque `chezmoi apply`, faire:
```bash
cp ~/.config/nvim/lazy-lock.json ~/.dotfiles/home/dot_config/nvim/lazy-lock.json
```

**Amélioration possible:** configurer chezmoi pour ignorer ce fichier (managed externally), ou `chezmoi add --follow` pour auto-sync.

## Nouvelle dépendance système

`tree-sitter` CLI est requis par nvim-treesitter branch main (build les parsers). Installé pendant Task 4 via `bun install -g tree-sitter-cli` (v0.26.8).

**Recommandation:** ajouter au setup reproductible (mise/homebrew/apt selon la plateforme) pour éviter le failure au premier setup sur une nouvelle machine.

## logsitter.nvim

**Statut:** conservé (non touché pendant migration).
**À investiguer:** origine/usage du plugin. Lazy-lock le montre sur `main` branch, pas d'erreur au démarrage. Décision reportée à une review future.

## Issues pré-existantes (pas causées par migration)

- `snacks.nvim`: 5 erreurs + 4 warnings en checkhealth (tectonic/pdflatex/mmdc manquants, `vim.ui.input` pas réglé sur `Snacks.input`, TS parsers manquants pour images). État identique au baseline.
- `mason`: 7 warnings pour langages non installés (Go, Ruby, PHP, etc.). Benign — user ne les utilise pas.

## Nouveaux mappings LSP à connaître (natifs 0.12)

Défauts activés au `LspAttach`:
- `K` — hover
- `grn` — rename
- `gra` — code action
- `grr` — references
- `gri` — implementation
- `gO` — document symbols

Customs user conservés:
- `gl` — diagnostic float
- `gK` — signature help

Anciens mappings retirés: `gk` (hover, remplacé par natif `K`), `K` custom (conflit avec natif).

## Prochaines étapes recommandées

- [ ] **Arbitrage snacks.nvim vs mini.nvim** — gros overlap (pickers, notif, statuscol). Décision reportée post-migration.
- [ ] **Arbitrage telescope vs snacks.picker** — même logique.
- [ ] **Investiguer logsitter.nvim** — garder ou dropper?
- [ ] **Setup tree-sitter CLI** dans le tooling reproductible.
- [ ] **Snacks.input setup** — résoudre l'erreur `vim.ui.input` dans checkhealth snacks si désiré.
- [ ] **Merge branch** — `git checkout main && git merge migration/nvim-0.12` après quelques jours d'usage stable.

## Merge final

**Ne pas merger immédiatement.** Attendre confirmation d'usage quotidien stable (2-7 jours). Puis:
```bash
cd ~/.dotfiles
git checkout main
git merge migration/nvim-0.12
git push
```
