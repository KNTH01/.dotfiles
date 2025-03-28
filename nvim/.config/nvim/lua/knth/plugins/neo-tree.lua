return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v2.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",

		"echasnovski/mini.nvim", -- NOTE: mini.icons doesn't work with neo-tree??

		-- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
	},

	config = function()
		vim.g.neo_tree_remove_legacy_commands = 1

		vim.keymap.set("n", "<Leader>e", [[:NeoTreeFloatToggle<cr>]])

		-- If you want icons for diagnostic errors, you'll need to define them somewhere:
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.INFO] = " ",
					[vim.diagnostic.severity.HINT] = "",
				},
				numhl = {
					-- If you were using numhl in your original definitions, add them here
				},
				texthl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
					[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
					[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
					[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
				},
				priority = 20, -- Optional: set the priority of the signs
			},
		})
    
		if vim.fn.argc() == 1 then
			local stat = vim.loop.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("neo-tree").setup({
					popup_border_style = "rounded",
					filesystem = {
						bind_to_cwd = false,
						follow_current_file = true,
						filtered_items = {
							hide_dotfiles = false,
							hide_gitignored = false,
							hide_hidden = false, -- only works on Windows for hidden files/directories
							hide_by_name = {
								"node_modules",
							},
							hide_by_pattern = { -- uses glob style patterns
								--"*.meta",
								--"*/src/*/tsconfig.json",
							},
							always_show = { -- remains visible even if other settings would normally hide it
								".gitignored",
								".env",
								".env.example",
							},
							never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
								--".DS_Store",
								--"thumbs.db"
							},
							never_show_by_pattern = { -- uses glob style patterns
								--".null-ls_*",
							},
						},
						hijack_netrw_behavior = "disabled",
					},
					window = {
						position = "right",
						mappings = {
							["<space>"] = "none",
						},
					},
					default_component_configs = {
						indent = {
							with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
							expander_collapsed = "",
							expander_expanded = "",
							expander_highlight = "NeoTreeExpander",
						},
					},
				})
			end
		end
	end,
}
