-----------------❰ Package Manager ❱-----------------

-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
  print("Installing Packer... Close and reopen Neovim")
end

-- runs PackerCompile on write
vim.api.nvim_exec(
  [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerCompile
  augroup end
]],
  false
)

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

return packer.startup({
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
    -- https://github.com/eddyekofo94/gruvbox-flat.nvim
    use("eddyekofo94/gruvbox-flat.nvim")

    -- Collection of common configurations for built-in LSP client
    use({ "neovim/nvim-lspconfig" })

    -- nvim-lsp-installer to auto install lsp language servers
    use({ "williamboman/nvim-lsp-installer" })

    -- vscode-like pictograms for neovim lsp completion items Topics
    use("onsails/lspkind-nvim")

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

    -- Snippets plugin
    use({
      "L3MON4D3/LuaSnip",
      requires = {
        -- snippets collection for a set of different programming languages for faster development
        "rafamadriz/friendly-snippets",
      },
      config = [[ require('knth/plugins/luasnip') ]],
    })

    -- Highlight, edit, and navigate code using a fast incremental parsing library
    use({
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      config = [[ require('knth/plugins/treesitter') ]],
    })

    -- Additional textobjects for treesitter
    use("nvim-treesitter/nvim-treesitter-textobjects")

    -- UI to select things (files, grep results, open buffers...)
    use({
      "nvim-telescope/telescope.nvim",
      config = [[ require('knth/plugins/telescope') ]],
      requires = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-media-files.nvim" },
    })

    -- use for status line
    use({
      "nvim-lualine/lualine.nvim",
      config = [[ require('knth/plugins/lualine') ]],
      requires = { "kyazdani42/nvim-web-devicons", opt = true },
    })

    -- Add indentation guides even on blank lines
    use({
      "lukas-reineke/indent-blankline.nvim",
      config = [[ require('knth/plugins/blankline') ]],
    })

    -- Add git related info in the signs columns and popups
    use({
      "lewis6991/gitsigns.nvim",
      config = [[ require('knth/plugins/gitsigns') ]],
      requires = { "nvim-lua/plenary.nvim" },
    })

    -- A super powerful autopairs for Neovim. It support multiple character
    use({
      "windwp/nvim-autopairs",
      config = [[ require('knth/plugins/autopairs') ]],
    })

    -- nvim notify
    use({
      "rcarriga/nvim-notify",
      config = [[ require('knth/plugins/notify') ]],
    })

    -- Better escape
    use({
      "max397574/better-escape.nvim",
      config = [[ require('knth/plugins/better_escape') ]],
    })

    -- AutoSave
    use({
      "Pocco81/AutoSave.nvim",
      config = [[ require('knth/plugins/autosave') ]],
    })

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
      "terrortylor/nvim-comment",
      config = [[ require('knth/plugins/nvim_comment') ]],
    })
    use("JoosepAlviste/nvim-ts-context-commentstring")

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

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
      packer.sync()
    end
  end,

  config = {
    -- Move to lua dir so impatient.nvim can cache it
    compile_path = vim.fn.stdpath("config") .. "/plugin/packer_compiled.lua",
  },
})
