return {
	-- Better escape
	"max397574/better-escape.nvim",
	config = function()
		require("better_escape").setup({
			mappings = {
				v = {
					j = {
						k = false,
					},
				},
			},
		})
	end,
}
