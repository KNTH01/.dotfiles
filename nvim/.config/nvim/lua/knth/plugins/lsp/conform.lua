return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		local conform = require("conform")

		local fs = require("vim.fs") -- Using vim.fs for file system operations

		-- Function to check for Biome config
		local function find_biome_config()
			local current_dir = vim.fn.getcwd()
			local config_files = {
				"biome.jsonc",
				"biome.json",
			}

			for _, file in ipairs(config_files) do
				if fs.find(file, { path = current_dir, upward = true })[1] then
					return true
				end
			end
			return false
		end

		-- Set formatters based on Biome config presence
		local js_formatter = find_biome_config() and "biome-check" or "prettier"

		local formatters_by_ft = {
			javascript = { js_formatter },
			typescript = { js_formatter },
			javascriptreact = { js_formatter },
			typescriptreact = { js_formatter },
			vue = { js_formatter },
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
