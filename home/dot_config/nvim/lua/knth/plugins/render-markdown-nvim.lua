return {
	"MeanderingProgrammer/render-markdown.nvim",
	opts = {},
	lazy = true,
	ft = "markdown",
	cmd = { "RenderMarkdown" },
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- for mini.icons
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
}
