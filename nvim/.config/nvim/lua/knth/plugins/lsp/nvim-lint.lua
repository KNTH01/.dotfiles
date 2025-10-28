return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Customize oxlint to use --type-aware flag
		lint.linters.oxlint = require("lint").linters.oxlint
		table.insert(lint.linters.oxlint.args, 1, '--type-aware')

		local fs = require("vim.fs") -- Using vim.fs for file system operations

		-- Function to check for ESLint config
		local function find_eslint_config()
			local current_dir = vim.fn.getcwd()
			local config_files = {
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.json",
				".eslintrc.yml",
				".eslintrc",
				-- "package.json", -- Check for eslintConfig in package.json
			}

			for _, file in ipairs(config_files) do
				if fs.find(file, { path = current_dir, upward = true })[1] then
					return true
				end
			end
			return false
		end

		-- Set linters based on config presence (ESLint > Biome > oxlint)
		local js_linter
		if find_eslint_config() then
			js_linter = "eslint_d"
		else
			js_linter = "oxlint"
		end

		lint.linters_by_ft = {
			javascript = { js_linter },
			typescript = { js_linter },
			javascriptreact = { js_linter },
			typescriptreact = { js_linter },
			svelte = { js_linter },
			vue = { js_linter },
			astro = { js_linter },
			markdown = { "markdownlint" },
		}

		-- Create autocommand which carries out the actual linting
		-- on the specified events.
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				-- Only run the linter in buffers that you can modify in order to
				-- avoid superfluous noise, notably within the handy LSP pop-ups that
				-- describe the hovered symbol using Markdown.
				if vim.opt_local.modifiable:get() then
					lint.try_lint()
				end
			end,
		})
	end,
}
