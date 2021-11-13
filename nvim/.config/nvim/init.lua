--
-- My nvim config
--

---------------❰ Leader Mapping ❱---------------
-- remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

---------------❰ Load/Source Configs ❱---------------
require("configs")
require("mappings")

-----------------❰ Package Manager ❱-----------------
-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

vim.api.nvim_exec(
  [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]],
  false
)

local use = require("packer").use
require("packer").startup(function()
  use("wbthomason/packer.nvim") -- Package manager

  -----------------❰ Plugins listing ❱-------------------

  -- checklist todo:
  -- 'lewis6991/impatient.nvim'
  -- 'nathom/filetype.nvim'

  -- Gruvbox theme
  use("morhetz/gruvbox")

  -- Collection of common configurations for built-in LSP client
  use({
    "neovim/nvim-lspconfig",
    config = [[ require('plugins/lsp_config') ]],
  })

  -- nvim-lsp-installer to auto install lsp language servers
  use({
    "williamboman/nvim-lsp-installer",
    confg = [[ require('plugins/lsp_installer") ]],
  })

  -- vscode-like pictograms for neovim lsp completion items Topics
  use({
    "onsails/lspkind-nvim",
    config = [[ require('plugins/lsp_kind') ]],
  })

  -- Utility functions for getting diagnostic status and progress messages from LSP servers, for use in the Neovim statusline
  use({
    "nvim-lua/lsp-status.nvim",
    config = [[ require('plugins/lsp_status') ]],
  })

  -- null-ls, for formatting
  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim", "nvim-lspconfig" },
    config = [[ require('plugins/null_ls') ]],
  })

  -- Autocompletion plugin
  use({ -- A completion plugin for neovim coded in Lua.
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for neovim builtin LSP client
      "hrsh7th/cmp-nvim-lua", -- nvim-cmp source for nvim lua
      "hrsh7th/cmp-buffer", -- nvim-cmp source for buffer words.
      "hrsh7th/cmp-path", -- nvim-cmp source for filesystem paths.
      "hrsh7th/cmp-calc", -- nvim-cmp source for math calculation.
      "saadparwaiz1/cmp_luasnip", -- luasnip completion source for nvim-cmp
    },
    config = [[ require('plugins/cmp') ]],
  })

  -- Snippets plugin
  use({
    "L3MON4D3/LuaSnip",
    requires = {
      -- snippets collection for a set of different programming languages for faster development
      "rafamadriz/friendly-snippets",
    },
  })

  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = [[ require('plugins/treesitter') ]],
  })

  -- Additional textobjects for treesitter
  use("nvim-treesitter/nvim-treesitter-textobjects")

  -- UI to select things (files, grep results, open buffers...)
  use({
    "nvim-telescope/telescope.nvim",
    config = [[ require('plugins/telescope') ]],
    requires = { "nvim-lua/plenary.nvim" },
  })

  -- Add indentation guides even on blank lines
  use({
    "lukas-reineke/indent-blankline.nvim",
    config = [[ require('plugins/blankline') ]],
  })

  -- Add git related info in the signs columns and popups
  use({
    "lewis6991/gitsigns.nvim",
    config = [[ require('plugins/gitsigns') ]],
    requires = { "nvim-lua/plenary.nvim" },
  })

  -- A super powerful autopairs for Neovim. It support multiple character
  use({
    "windwp/nvim-autopairs",
    config = [[ require('plugins/autopairs') ]],
  })

  -- nvim notify
  use({
    "rcarriga/nvim-notify",
    config = [[ require('plugins/notify') ]],
  })

  -- Better escape
  use({
    "max397574/better-escape.nvim",
    config = [[ require('plugins/better_escape') ]],
  })

  -- AutoSave
  use({
    "Pocco81/AutoSave.nvim",
    config = [[ require('plugins/autosave') ]],
  })

  -- Smooth scrolling
  use({
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end,
  })

  -- Colorizer
  use({
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  })

  -- Git commands in nvim
  use("tpope/vim-fugitive")

  -- Fugitive-companion to interact with github
  use("tpope/vim-rhubarb")

  -- "gc" to comment visual regions/lines
  use("tpope/vim-commentary")

  -- Fancier statusline
  use("itchyny/lightline.vim")

  -- rust goodness?
  use("simrat39/rust-tools.nvim")

  -- todo: List of plugins to check out
  -- bufferline
  -- feline (statusline)
  -- mundo
  -- harpoon
  -- ...
  --
end)

-------------
