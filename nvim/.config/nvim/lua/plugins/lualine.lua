local status, lualine = pcall(require, "lualine")
if not status then
  return
end

lualine.setup({
  options = {
    -- theme = "gruvbox-flat",
    -- theme = "onedarkpro",
    theme = "catppuccin",
    section_separators = "",
    component_separators = "",
  },
  sections = {
    lualine_c = {
      { "filename", path = 1 },
    },
  },
})
