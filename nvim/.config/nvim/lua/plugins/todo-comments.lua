return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{ "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Open TODOs list in Telescope" },
	},
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		-- https://github.com/folke/todo-comments.nvim
	},
}
