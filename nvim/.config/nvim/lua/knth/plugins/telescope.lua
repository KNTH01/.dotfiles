return {
	-- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{
		"nvim-telescope/telescope.nvim",

		enabled = false,

		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				-- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},

			"nvim-telescope/telescope-ui-select.nvim", -- sets vim.ui.select to telescope
			"nvim-telescope/telescope-media-files.nvim",
			"echasnovski/mini.nvim", -- mini.icons
			"folke/todo-comments.nvim",
		},

		config = function()
			-- Telescope config
			-- Telescope

			local telescope_setup, telescope = pcall(require, "telescope")
			if not telescope_setup then
				return
			end

			local actions_setup, actions = pcall(require, "telescope.actions")
			if not actions_setup then
				return
			end

			telescope.setup({
				defaults = {
					-- prompt_prefix = " ",
					-- selection_caret = " ",
					prompt_prefix = "🔎︎ ",
					selection_caret = "➤ ",
					path_display = { "smart" },
					pickers = {
						-- Default configuration for builtin pickers goes here:
						-- picker_name = {
						--   picker_config_key = value,
						--   ...
						-- }
						-- Now the picker_config_key will be applied every time you call this
						-- builtin picker
					},
					extensions = {
						media_files = {
							-- filetypes whitelist
							-- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
							filetypes = { "png", "webp", "jpg", "jpeg" },
							find_cmd = "rg", -- find command (defaults to `fd`)
						},

						fzf = {
							fuzzy = true, -- false will only do exact matching
							override_generic_sorter = true, -- override the generic sorter
							override_file_sorter = true, -- override the file sorter
							case_mode = "smart_case", -- or "ignore_case" or "respect_case"
						},

						["ui-select"] = {
							require("telescope.themes").get_dropdown(),
						},
						-- Your extension configuration goes here:
						-- extension_name = {
						--   extension_config_key = value,
						-- }
						-- please take a look at the readme of the extension you want to configure
					},
					mappings = {
						i = {
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-c>"] = actions.close,
							["<Down>"] = actions.move_selection_next,
							["<Up>"] = actions.move_selection_previous,
							["<CR>"] = actions.select_default,
							["<C-x>"] = actions.select_horizontal,
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,
							["<C-u>"] = actions.preview_scrolling_up,
							["<C-d>"] = actions.preview_scrolling_down,
							-- ["<C-u>"] = false,
							-- ["<C-d>"] = false,

							["<PageUp>"] = actions.results_scrolling_up,
							["<PageDown>"] = actions.results_scrolling_down,
							["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
							["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-l>"] = actions.complete_tag,
							["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
						},
						n = {
							["<esc>"] = actions.close,
							["<CR>"] = actions.select_default,
							["<C-x>"] = actions.select_horizontal,
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,
							["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
							["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
							["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
							["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["j"] = actions.move_selection_next,
							["k"] = actions.move_selection_previous,
							["H"] = actions.move_to_top,
							["M"] = actions.move_to_middle,
							["L"] = actions.move_to_bottom,
							["<Down>"] = actions.move_selection_next,
							["<Up>"] = actions.move_selection_previous,
							["gg"] = actions.move_to_top,
							["G"] = actions.move_to_bottom,
							["<C-u>"] = actions.preview_scrolling_up,
							["<C-d>"] = actions.preview_scrolling_down,
							["<PageUp>"] = actions.results_scrolling_up,
							["<PageDown>"] = actions.results_scrolling_down,
							["?"] = actions.which_key,
						},
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
					-- entry_prefix = "  ",
					-- winblend = 0,
					-- border = {},
					-- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					-- color_devicons = true,
					-- use_less = true,
					-- set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "media_files")
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- mappings
			local builtin = require("telescope.builtin")

			-- vim.keymap.set("n", "<Leader>FF", builtin.git_files, { desc = "[F]ind Git [F]iles" })
			-- vim.keymap.set("n", "<Leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
			-- vim.keymap.set("n", "<Leader>fg", builtin.live_grep, { desc = "[F]ind [G]rep" })
			-- vim.keymap.set("n", "<Leader>fw", builtin.grep_string, { desc = "[F]ind [W]ord" })
			-- vim.keymap.set("n", "<Leader>fb", builtin.git_branches, { desc = "[F]ind Git [B]ranches" })
			-- vim.keymap.set("n", "<Leader>fh", builtin.help_tags, { desc = "[F]ind [h]elp" })
			-- vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
			-- vim.keymap.set("n", "<leader>m", builtin.marks, { desc = "[F]ind [M]arks" })
			-- vim.keymap.set("n", "<leader>fd", function()
			-- 	builtin.diagnostics({ bufnr = 0 })
			-- end, { desc = "[F]ind [D]iagnostics" })
			-- vim.keymap.set("n", "<leader>th", builtin.colorscheme, { desc = 'find ColorScheme ("th" for theme)' })
			-- vim.keymap.set("n", "<leader>ci", builtin.git_commits, { desc = 'find Git commits ("ci" for commit)' })
			-- vim.keymap.set(
			-- 	"n",
			-- 	"<Leader><space>",
			-- 	builtin.current_buffer_fuzzy_find,
			-- 	{ desc = "Fuzzy Find in Current Buffer" }
			-- )
			-- vim.keymap.set("n", "<Leader>fp", ":Telescope media_files<CR>", { desc = "[F]ind media" })
		end,
	},
}
