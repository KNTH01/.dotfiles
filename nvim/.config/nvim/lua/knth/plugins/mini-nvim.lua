return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		require("mini.ai").setup()

		require("mini.pairs").setup()

		require("mini.surround").setup()

		require("mini.bracketed").setup()

		require("mini.icons").setup()
		MiniIcons.mock_nvim_web_devicons() -- see: :h MiniIcons.mock_nvim_web_devicons()

		require("mini.files").setup()
		vim.keymap.set("n", "-", ":lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<cr>", { desc = "Minifiles" })

		require("mini.statusline").setup({
			content = {
				active = function()
					local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
					local git = MiniStatusline.section_git({ trunc_width = 40 })
					local diff = MiniStatusline.section_diff({ trunc_width = 75 })
					local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
					local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
					local filename = MiniStatusline.section_filename({ trunc_width = 140 })
					local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
					local location = MiniStatusline.section_location({ trunc_width = 75 })
					local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

					-- Set MiniStatuslineLazyPkg to have blue text on a dark background
					vim.api.nvim_set_hl(0, "MiniStatuslineLazyPkg", { fg = "#61AFEF", bg = "#1E2127" })

					return MiniStatusline.combine_groups({
						{ hl = mode_hl, strings = { mode } },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
						"%<", -- Mark general truncate point
						{ hl = "MiniStatuslineFilename", strings = { filename } },
						"%=", -- End left alignment

						-- Add lazy updates to your statusline, using MiniStatuslineDevinfo highlight
						{ hl = "MiniStatuslineLazyPkg", strings = { require("lazy.status").updates() } },

						{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
						{ hl = mode_hl, strings = { search, location } },
					})
				end,

				inactive = function()
					local filename = MiniStatusline.section_filename({ trunc_width = 140 })
					return MiniStatusline.combine_groups({
						{ hl = "MiniStatuslineInactive", strings = { filename } },
					})
				end,
			},
			use_icons = true,
		})
	end,
}
