return {
  {
    -- Catppuccin
    -- https://github.com/catppuccin/nvim
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    config = function()
      require("catppuccin").setup({
        integration = {
          bufferline = true,
          nvimtree = true,
          illuminate = true,
        }
      })



      -- Catppuccin
      -- catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
      -- vim.cmd.colorscheme("catppuccin-latte")
      vim.cmd.colorscheme("catppuccin-frappe")
    end
  },
}
