return {
	"gaelph/logsitter.nvim",

	keys = {
		{
			"<leader>lg",
			function()
				require("logsitter").log()
			end,
			desc = "Call to LogSitter",
		},
	},

	config = function()
		local logsitter = require("logsitter")
		logsitter.register(require("knth.logsitter.rust_logger"), { "rust" })
	end,
}
