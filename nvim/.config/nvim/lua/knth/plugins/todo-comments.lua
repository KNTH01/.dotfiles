return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<leader>ft",
			function()
				Snacks.picker.todo_comments()
			end
,
			desc = "TODOs",
		},
	},
	config = function()
		local todo_comments = require("todo-comments")

		vim.keymap.set("n", "]t", function()
			todo_comments.jump_next()
		end, { desc = "Next todo comment" })

		vim.keymap.set("n", "[t", function()
			todo_comments.jump_prev()
		end, { desc = "Previous todo comment" })

		todo_comments.setup()
	end,
}
