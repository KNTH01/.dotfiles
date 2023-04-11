-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall

local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

treesitter_configs.setup({
  highlight = {
    enable = true, -- `false` will disable the whole extension
  },

  -- enable indentation
  indent = { enable = true, disable = { "yaml" } },

  -- enable autotagging (w/ nvim-ts-autotag plugin)
  autotag = { enable = true },

  -- ensure these language parsers are installed
  ensure_installed = {
    "help",
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
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,
})
