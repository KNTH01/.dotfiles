return {
	-- AutoSave
	"pocco81/auto-save.nvim",
	config = function()
		vim.api.nvim_set_keymap("n", "<leader>A", ":ASToggle<CR>", {})
		require("auto-save").setup({
			condition = function(buf)
				local excluded_filetypes = { "harpoon" }
				local filetype = vim.bo[buf].filetype

				for _, ft in ipairs(excluded_filetypes) do
					if ft == filetype then
						return false
					end
				end

				return true
			end,

			-- execution_message = {
			-- 	message = function() -- message to print on save
			-- 		-- return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
			-- 		-- disable auto-save message
			-- 		return "toto"
			-- 	end,
			-- },
		})
	end,
}
