-- font
vim.opt.guifont = "DroidSansMono Nerd Font 12"

-- gruvbox-flat config
vim.g.gruvbox_flat_style = "dark"
-- make comment italics
vim.g.gruvbox_italic_functions = true
-- make functions italic
vim.g.gruvbox_italic_comments = true
-- make keyword italic
vim.g.gruvbox_italic_keywords = true
-- set a darker background_color for sidebar, e.g: NvimTree
vim.g.gruvbox_dark_sidebar = true
-- set a darker background_color for float windows, e.g: Notify
vim.g.gruvbox_dark_float = true
-- set the background to be not transparent
vim.g.gruvbox_transparent = false

-- set gruvbox theme
-- must be set AFTER the theme's config
vim.cmd([[colorscheme gruvbox-flat]])

-- set onedarkpro light theme
local onedarkpro = require("onedarkpro")
onedarkpro.load()

-- do not forget to update lualine theme: `lua/{user}/plugins/lualine.lua`
