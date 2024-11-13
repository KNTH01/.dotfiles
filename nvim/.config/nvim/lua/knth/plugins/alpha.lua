return {
	"goolord/alpha-nvim",
	dependencies = {
		"echasnovski/mini.nvim", -- mini.icons
	},
	event = "VimEnter",
	config = function()
		local dashboard = require("alpha.themes.dashboard")
		local logo = [[
 _   _                 _
| \ | |               (_)
|  \| | ___  _____   ___ _ __ ___
| . ` |/ _ \/ _ \ \ / / | '_ ` _ \
| |\  |  __/ (_) \ V /| | | | | | |
\_| \_/\___|\___/ \_/ |_|_| |_| |_|


     _   __ _   _ _____ _   _
    | | / /| \ | |_   _| | | |
    | |/ / |  \| | | | | |_| |
    |    \ | . ` | | | |  _  |
    | |\  \| |\  | | | | | | |
    \_| \_/\_| \_/ \_/ \_| |_/
]]

		dashboard.section.header.val = vim.split(logo, "\n")
		dashboard.section.buttons.val = {
			dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
			dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
			dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
			dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
			dashboard.button("l", " " .. " Lazy", ":Lazy<CR>"),
			dashboard.button("q", " " .. " Quit", ":qa<CR>"),
		}
		for _, button in ipairs(dashboard.section.buttons.val) do
			button.opts.hl = "AlphaButtons"
			button.opts.hl_shortcut = "AlphaShortcut"
		end

		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.buttons.opts.hl = "AlphaButtons"
		dashboard.section.footer.opts.hl = "AlphaFooter"
		dashboard.opts.layout[1].val = 8

		require("alpha").setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
