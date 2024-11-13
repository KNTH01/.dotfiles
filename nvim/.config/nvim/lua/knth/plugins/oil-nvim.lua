return {
	"stevearc/oil.nvim",
	opts = {},
	dependencies = {
		"echasnovski/mini.nvim",
		-- "nvim-tree/nvim-web-devicons",
	},
	config = function()
		local oil = require("oil")

		oil.setup()

		vim.keymap.set("n", "-", oil.open, { desc = "Open parent directory" })
	end,
}
