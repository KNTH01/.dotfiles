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

	config = function()
		-- Function to get Obsidian commands dynamically
		local function get_obsidian_commands()
			local commands = {}
			for name, cmd in pairs(vim.api.nvim_get_commands({})) do
				if name:match("^Obsidian") then
					table.insert(commands, { name, cmd.definition or "No description available" })
				end
			end
			return commands
		end

		-- Create a custom Telescope picker for Obsidian commands
		local function obsidian_commands_picker()
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			require("telescope.builtin").find_files({
				prompt_title = "Obsidian Commands",
				results_title = "Commands",
				finder = require("telescope.finders").new_table({
					results = get_obsidian_commands(),
					entry_maker = function(entry)
						return {
							value = entry[1],
							display = entry[1] .. " - " .. entry[2],
							ordinal = entry[1],
						}
					end,
				}),
				sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
				attach_mappings = function(prompt_bufnr, map)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						vim.cmd(selection.value)
					end)
					return true
				end,
			})
		end

		vim.keymap.set("n", "<leader>os", ":ObsidianSearch<cr>", { desc = "Obsidian search" })
		vim.keymap.set("n", "<leader>on", ":ObsidianNew<cr>", { desc = "Obsidian create a new note" })
		vim.keymap.set(
			"n",
			"<leader>op",
			obsidian_commands_picker,
			{ buffer = true, noremap = true, silent = true, desc = "Obsidian Commands" }
		)

		require("obsidian").setup({
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
			mappings = {
				-- Overrides the 'gd' mapping to work on markdown/wiki links within your vault.
				["gd"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
			},
		})
	end,
}
