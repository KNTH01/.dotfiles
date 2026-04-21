return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		local conform = require("conform")

		local function has_biome_config(bufnr)
			local buffer_path = vim.api.nvim_buf_get_name(bufnr)
			local search_path = buffer_path ~= "" and vim.fs.dirname(buffer_path) or vim.fn.getcwd()

			return vim.fs.find({ "biome.json", "biome.jsonc" }, {
				upward = true,
				path = search_path,
				type = "file",
			})[1] ~= nil
		end

		local function biome_check_or_oxfmt(bufnr)
			return has_biome_config(bufnr) and { "biome-check" } or { "oxfmt" }
		end

		local formatters_by_ft = {
			javascript = biome_check_or_oxfmt,
			typescript = biome_check_or_oxfmt,
			javascriptreact = biome_check_or_oxfmt,
			typescriptreact = biome_check_or_oxfmt,
			json = biome_check_or_oxfmt,
			css = biome_check_or_oxfmt,
			astro = { "oxfmt" },
			svelte = { "oxfmt" },
			html = { "oxfmt" },
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
		})

		vim.keymap.set({ "n", "v" }, "<leader>fm", function()
			conform.format({
				lsp_fallback = true,
				async = true,
				timeout_ms = 500,
			}, function(err)
				if err then return end
				vim.api.nvim_exec_autocmds("User", {
					pattern = "KnthLint",
					modeline = false,
					data = { bufnr = vim.api.nvim_get_current_buf() },
				})
			end)
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
