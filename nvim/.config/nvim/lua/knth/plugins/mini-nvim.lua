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
	end,
}
