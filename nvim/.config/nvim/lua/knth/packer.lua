local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  print("Fail to load Packer")
  return
end

return lazy.setup({
  -----------------❰ Themes listing ❱-------------------

  -- One Dark Pro theme
  -- https://github.com/olimorris/onedarkpro.nvim
  "olimorris/onedarkpro.nvim",

  -- Catppuccin
  -- https://github.com/catppuccin/nvim
  { "catppuccin/nvim",                          as = "catppuccin" },

  -----------------❰ Plugins listing ❱-------------------

  -- lsp-zero
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v1.x",
    dependencies = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- null-ls
      { "jose-elias-alvarez/null-ls.nvim" },
      { "jay-babu/mason-null-ls.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lua" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "rafamadriz/friendly-snippets" },
    },
    config = [[ require("knth.plugins.lsp-zero") ]]
  },

  -- Rust LSP
  "simrat39/rust-tools.nvim",

  -- Telescope
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "nvim-telescope/telescope.nvim",
    config = [[ require('knth/plugins/telescope') ]],
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-media-files.nvim" },
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config =
    [[ require('knth.plugins.treesitter') ]],
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- autoclose tags
      "windwp/nvim-ts-autotag",
      -- A super powerful autopairs for Neovim. It support multiple character
      { "windwp/nvim-autopairs", config = [[ require('knth.plugins.autopairs') ]] },
    }
  },
  "nvim-treesitter/playground",


  -- navigation with `s` and `S` in nvim
  {
    "ggandor/leap.nvim",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- use for status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
  },

  -- Add indentation guides even on blank lines
  {
    "lukas-reineke/indent-blankline.nvim",
  },

  -- Add git related info in the signs columns and popups
  {
    "lewis6991/gitsigns.nvim",
    config = [[ require('knth.plugins.gitsigns') ]],
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- nvim notify
  { "rcarriga/nvim-notify" },

  -- Better escape
  {
    "max397574/better-escape.nvim",
    config = [[ require('knth/plugins/better_escape') ]],
  },

  -- AutoSave
  { "Pocco81/AutoSave.nvim" },

  -- A File Explorer For Neovim Written In Lua
  {
    "kyazdani42/nvim-tree.lua",
    config = [[ require('knth/plugins/nvim_tree') ]],
  },

  -- webdev icons
  {
    "kyazdani42/nvim-web-devicons",
    config = [[ require('knth/plugins/webdevicons') ]],
  },

  -- tagviewer
  {
    "liuchengxu/vista.vim",
    config = [[ require('knth/plugins/vista') ]],
  },

  -- commenting plugin
  {
    "numToStr/Comment.nvim",
    config = [[ require('knth/plugins/comment') ]],
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    tag = "v2.*",
    config = [[ require('knth/plugins/bufferline') ]],
    dependencies = { "moll/vim-bbye" },
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end,
  },

  -- Trying NeoGit
  {
    "TimUntersberger/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("neogit").setup({})
    end,
  },

  -- Colorizer
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- Git commands in nvim
  {
    "tpope/vim-fugitive",
    config = [[ require('knth.plugins.vim-fugitive') ]]
  },

  -- Fugitive-companion to interact with github
  "tpope/vim-rhubarb",

  -- `]q` and `[q` for QuickFix List navigation
  "tpope/vim-unimpaired",

  -- `ds`, `cs`, 'yss' cmds, eg: `cs"'`, `ysiw"`
  "tpope/vim-surround",

  -- tmux & split window navigation
  "christoomey/vim-tmux-navigator",

  {
    'mbbill/undotree',
    config = function() vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle) end
  },

})
