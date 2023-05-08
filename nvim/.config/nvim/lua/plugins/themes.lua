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
          nvimtree = true
        }
      })
    end
  },
}
