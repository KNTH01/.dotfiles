return {
	"stevearc/oil.nvim",
	opts = {},
	dependencies = {
		"echasnovski/mini.nvim", -- mini.icons
	},
	config = function()
		local oil = require("oil")

		oil.setup()

		vim.keymap.set("n", "-", oil.open, { desc = "Open parent directory" })
	end,
}
