return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		preset = "helix",
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		-- https://github.com/folke/which-key.nvim
	},
}
