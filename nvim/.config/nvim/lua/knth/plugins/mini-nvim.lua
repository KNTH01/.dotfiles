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
	end,
}
