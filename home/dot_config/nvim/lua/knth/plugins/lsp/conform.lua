return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		local conform = require("conform")

		local js_formatter = "oxfmt"

		local formatters_by_ft = {
			javascript = { js_formatter },
			typescript = { js_formatter },
			javascriptreact = { js_formatter },
			typescriptreact = { js_formatter },
			astro = { js_formatter },
			svelte = { js_formatter },
			css = { js_formatter },
			html = { js_formatter },
			json = { js_formatter },
			yaml = { "prettier" },
			markdown = { "prettier" },
			graphql = { "prettier" },
			liquid = { "prettier" },
			lua = { "stylua" },
			nix = { "nixfmt" },
			fish = { "fish_indent" },
		}

		conform.setup({
			formatters_by_ft = formatters_by_ft,

			-- format_on_save = js_formatter == "biome-check" and {
			-- 	lsp_fallback = true,
			-- 	async = false,
			-- 	timeout_ms = 1000,
			-- } or nil,
		})

		vim.keymap.set({ "n", "v" }, "<leader>fm", function()
			conform.format({
				lsp_fallback = true,
				async = true,
				timeout_ms = 500,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
