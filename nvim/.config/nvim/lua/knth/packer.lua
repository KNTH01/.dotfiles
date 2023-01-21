-----------------❰ Package Manager ❱-----------------

-- Install packer
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()
----

local status_ok, packer = pcall(require, "packer")
if not status_ok then
  print("Fail to load Packer")
  return
end

return packer.startup(function(use)
  use("wbthomason/packer.nvim") -- Package manager

  -----------------❰ Plugins listing ❱-------------------

  -- One Dark Pro theme
  -- https://github.com/olimorris/onedarkpro.nvim
  use("olimorris/onedarkpro.nvim")

  -- Gruvbox theme
  -- https://github.com/eddyekofo94/gruvbox-flat.nvim
  use("eddyekofo94/gruvbox-flat.nvim")

  -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
  use({
    "williamboman/mason.nvim",
    requires = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = [[ require('knth/lsp/mason') ]],
  })

  -- Collection of common configurations for built-in LSP client
  use({ "neovim/nvim-lspconfig" })

  -- Utility functions for getting diagnostic status and progress messages from LSP servers, for use in the Neovim statusline
  use({
    "nvim-lua/lsp-status.nvim",
    config = [[ require('knth/lsp/lsp_status') ]],
  })

  -- null-ls, for formatting
  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim", "nvim-lspconfig" },
    config = [[ require('knth/plugins/null_ls') ]],
  })
  use({ "jayp0521/mason-null-ls.nvim" })

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
      "hrsh7th/cmp-cmdline", -- cmdline completions
    },
  })

  -- enhanced UI to LSP experience
  use({ "glepnir/lspsaga.nvim", branch = "main" })
  -- vscode-like pictograms for neovim lsp completion items Topics
  use("onsails/lspkind-nvim")

  -- Snippets plugin
  use({
    "L3MON4D3/LuaSnip",
    requires = {
      -- snippets collection for a set of different programming languages for faster development
      "rafamadriz/friendly-snippets",
    },
    config = [[ require('knth/plugins/luasnip') ]],
  })

  -- UI to select things (files, grep results, open buffers...)
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use({
    "nvim-telescope/telescope.nvim",
    config = [[ require('knth/plugins/telescope') ]],
    requires = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-media-files.nvim" },
  })

  --
  --

  -- TreeSitter
  use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate", config = [[ require('knth.plugins.treesitter') ]] })
  use("nvim-treesitter/nvim-treesitter-textobjects")
  use("nvim-treesitter/playground")

  -- autoclose tags
  use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" })
  -- A super powerful autopairs for Neovim. It support multiple character
  use({ "windwp/nvim-autopairs" })

  --
  -- LIST
  --
  --
  --
  --

  -- navigation with `s` and `S` in nvim
  use({
    "ggandor/leap.nvim",
    config = function()
      require("leap").add_default_mappings()
    end,
  })

  -- use for status line
  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
  })

  -- Add indentation guides even on blank lines
  use({
    "lukas-reineke/indent-blankline.nvim",
  })

  -- Add git related info in the signs columns and popups
  use({
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
  })

  -- nvim notify
  use({ "rcarriga/nvim-notify" })

  -- Better escape
  use({
    "max397574/better-escape.nvim",
    config = [[ require('knth/plugins/better_escape') ]],
  })

  -- AutoSave
  use({ "Pocco81/AutoSave.nvim" })

  -- A File Explorer For Neovim Written In Lua
  use({
    "kyazdani42/nvim-tree.lua",
    config = [[ require('knth/plugins/nvim_tree') ]],
  })

  -- webdev icons
  use({
    "kyazdani42/nvim-web-devicons",
    config = [[ require('knth/plugins/webdevicons') ]],
  })

  -- tagviewer
  use({
    "liuchengxu/vista.vim",
    config = [[ require('knth/plugins/vista') ]],
  })

  -- commenting plugin
  use({
    "numToStr/Comment.nvim",
    config = [[ require('knth/plugins/comment') ]],
  })

  -- bufferline
  use({
    "akinsho/bufferline.nvim",
    tag = "v2.*",
    config = [[ require('knth/plugins/bufferline') ]],
    requires = { "moll/vim-bbye" },
  })

  -- Smooth scrolling
  use({
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end,
  })

  -- Trying NeoGit
  use({
    "TimUntersberger/neogit",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("neogit").setup({})
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

  -- `]q` and `[q` for QuickFix List navigation
  use("tpope/vim-unimpaired")

  -- `ds`, `cs`, 'yss' cmds, eg: `cs"'`, `ysiw"`
  use("tpope/vim-surround")

  -- rust goodness
  use("simrat39/rust-tools.nvim")

  -- tmux & split window navigation
  use("christoomey/vim-tmux-navigator")

  -- todo: List of plugins to check out
  -- bufferline
  -- feline (statusline)
  -- mundo
  -- harpoon
  -- folke/trouble.nvim
  -- ...

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    packer.sync()
  end
end)
