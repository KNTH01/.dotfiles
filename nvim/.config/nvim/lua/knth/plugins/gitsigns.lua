return {
	-- Add git related info in the signs columns and popups
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, desc)
				vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
			end

			-- Navigation
			map("n", "]h", gs.next_hunk, "Next Hunk")
			map("n", "[h", gs.prev_hunk, "Prev Hunk")

			map("n", "<leader>gb", function()
				gs.blame_line({ full = true })
			end, "Blame line")

      -- Doesn't work for now, is it because I don't have inlay?
			-- map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")

			-- map("n", "<leader>gd", gs.diffthis, "Diff this")
			-- map("n", "<leader>gD", function()
			-- 	gs.diffthis("~")
			-- end, "Diff this ~")
		end,
	},
}
