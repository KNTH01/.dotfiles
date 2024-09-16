local my_vault = "/home/knth/documents/obsidian-vaults/KNTH"

return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	event = {
		-- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		-- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
		-- refer to `:h file-pattern` for more examples
		-- "BufReadPre path/to/my-vault/*.md",
		-- "BufNewFile path/to/my-vault/*.md",
		--
		"BufReadPre "
			.. my_vault
			.. "/*.md",
		"BufNewFile " .. my_vault .. "/*.md",
	},
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
		-- see below for full list of optional dependencies 👇
	},
	opts = {
		workspaces = {
			{
				name = "KNTH",
				path = my_vault,
			},
			-- {
			--     name = "work",
			--     path = "~/vaults/work",
			-- },
		},
		ui = {
			enable = false,
		},
	},
}
