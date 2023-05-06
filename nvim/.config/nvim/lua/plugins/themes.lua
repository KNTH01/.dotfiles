return {
  {
    -- Catppuccin
    -- https://github.com/catppuccin/nvim
    "catppuccin/nvim",
    name = "catppuccin",
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
