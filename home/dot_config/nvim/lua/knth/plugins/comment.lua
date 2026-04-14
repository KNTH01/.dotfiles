return {
	-- -- commenting plugin
	-- "numToStr/Comment.nvim",
	-- event = { "BufReadPre", "BufNewFile" },
	-- dependencies = {
	--   "JoosepAlviste/nvim-ts-context-commentstring",
	-- },
	-- config = function()
	--   local comment = require("Comment")
	--   local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")
	--
	--   comment.setup({
	--     -- for commenting tsx, jsx, svelte, html files
	--     pre_hook = ts_context_commentstring.create_pre_hook(),
	--   })
	-- end
	{
		"folke/ts-comments.nvim",
		opts = {},
		event = "VeryLazy",
		enabled = vim.fn.has("nvim-0.10.0") == 1,
	},
}
