return {
	-- AutoSave
	"pocco81/auto-save.nvim",
	config = function()
		vim.api.nvim_set_keymap("n", "<leader>A", ":ASToggle<CR>", {})
		require("auto-save").setup({
			condition = function(buf)
				-- First check if buffer is valid
				if not buf or not vim.api.nvim_buf_is_valid(buf) then
					return false
				end

				local excluded_filetypes = {
					"NeogitStatus",
					"NeogitDiffView",
					"harpoon",
				}
				local filetype = vim.bo[buf].filetype

				for _, ft in ipairs(excluded_filetypes) do
					if ft == filetype then
						return false
					end
				end

				return true
			end,
		})
	end,
}
