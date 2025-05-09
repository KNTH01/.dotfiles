return {
	-- use for status line
	"nvim-lualine/lualine.nvim",

	enabled = false,

	dependencies = {
		"echasnovski/mini.nvim", -- mini.icons
	},

	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		lualine.setup({
			options = {
				-- theme = "gruvbox-flat",
				-- theme = "onedarkpro",
				theme = "catppuccin",
				section_separators = "",
				component_separators = "",
			},
			winbar = {
				lualine_y = {
					{ "filename", path = 1 },
				},
			},
			sections = {
				lualine_c = {
					{ "filename", path = 1 },
				},
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
