return {
	enabled = false,

	"akinsho/bufferline.nvim",
	version = "v4.*",
	dependencies = {
		"moll/vim-bbye",
		"echasnovski/mini.nvim", -- mini.icons
	},
	config = function()
		local status_ok, bufferline = pcall(require, "bufferline")
		if not status_ok then
			return
		end

		bufferline.setup({
			highlights = require("catppuccin.groups.integrations.bufferline").get(),
			options = {
				numbers = "none", -- | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
				close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
				right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
				left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
				middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
				separator_style = "slope", -- | "thick" | "thin" | "slant" | "slope" :h bufferline-styling
				show_buffer_icons = true,
			},
		})
	end,
}
