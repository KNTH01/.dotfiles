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
		local javascript_logger = require("logsitter.lang.javascript")

		logsitter.register(require("knth.logsitter.rust-logger"), { "rust" })
		logsitter.register(javascript_logger, { "vue", "astro", "svelte" })
	end,
}
