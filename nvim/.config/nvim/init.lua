--
-- My nvim config
--

---------------❰ Leader Mapping ❱---------------
-- remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

---------------❰ Load/Source Configs ❱---------------
-- plugin config to improve start-up time.
-- it should be always on top on init.lua file
-- impatient needs to be setup before any other lua plugin is loaded
require("impatient")

-- Easily speed up your neovim startup time!
-- can be removed after upgrading to neovim v0.6
vim.g.did_load_filetypes = 1

require("configs")
require("mappings")

-----------------❰ Package Manager ❱-----------------
-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

-- runs PackerCompileon write
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
require("packer").startup({
  function()
    use("wbthomason/packer.nvim") -- Package manager

    -----------------❰ Plugins listing ❱-------------------

    -- checklist todo:
    -- 'lewis6991/impatient.nvim'
    -- 'nathom/filetype.nvim'
    use({ -- Speed up loading Lua modules in Neovim to improve startup time.
      "lewis6991/impatient.nvim",
    })

    use({ --  Easily speed up your neovim startup time!. A faster version of filetype.vim
      "nathom/filetype.nvim",
    })

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
      config = [[ require('plugins/lsp_installer') ]],
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
      config = [[ require('plugins/luasnip') ]],
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

    -- A File Explorer For Neovim Written In Lua
    use({
      "kyazdani42/nvim-tree.lua",
      config = [[ require('plugins/nvim_tree') ]],
    })

    -- webdev icons
    use({
      "kyazdani42/nvim-web-devicons",
      config = [[ require('plugins/webdevicons') ]],
    })

    -- tagviewer
    use({
      "liuchengxu/vista.vim",
      config = [[require('plugins/vista')]],
    })

    -- commenting plugin
    use({
      "b3nj5m1n/kommentary",
      config = [[require('plugins/kommentary')]],
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

    -- Fancier statusline
    use("itchyny/lightline.vim")

    -- rust goodness?
    use("simrat39/rust-tools.nvim")

    -- todo: List of plugins to check out
    -- bufferline
    -- feline (statusline)
    -- mundo
    -- harpoon
    -- folke/trouble.nvim
    -- glepnir/lspsaga.nvim
    -- ...
    --
  end,

  config = {
    -- Move to lua dir so impatient.nvim can cache it
    compile_path = vim.fn.stdpath("config") .. "/plugin/packer_compiled.lua",
  },
})
