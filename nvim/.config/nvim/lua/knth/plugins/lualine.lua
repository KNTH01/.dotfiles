require("lualine").setup({
  options = {
    -- theme = "gruvbox-flat",
    theme = "onedarkpro",
    section_separators = "",
    component_separators = "",
  },
  sections = {
    lualine_c = {
      { "filename", path = 1 },
    },
  },
})
