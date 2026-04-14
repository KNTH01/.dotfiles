return {
	"eandrju/cellular-automaton.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
    vim.keymap.set("n", "<leader>clg", "<cmd>CellularAutomaton game_of_life<CR>")
		vim.keymap.set("n", "<leader>clr", "<cmd>CellularAutomaton make_it_rain<CR>")
		vim.keymap.set("n", "<leader>cls", "<cmd>CellularAutomaton scramble<CR>")
	end,
}
