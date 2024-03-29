return {

  -----------------❰ Plugins listing ❱-------------------

  -- navigation with `s` and `S` in nvim
  -- {
  --   "ggandor/leap.nvim",
  --   config = function()
  --     require("leap").add_default_mappings()
  --   end,
  -- },


  -- Add indentation guides even on blank lines
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      -- Config blankline
      vim.g.indent_blankline_char = "┊"
      vim.g.indent_blankline_filetype_exclude = { "help", "packer" }
      vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
      vim.g.indent_blankline_char_highlight = "LineNr"
      vim.g.indent_blankline_show_trailing_blankline_indent = false
    end
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end,
  },

  -- Colorizer
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
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
}
