return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Customize oxlint to use --type-aware flag
		lint.linters.oxlint = require("lint").linters.oxlint
		table.insert(lint.linters.oxlint.args, 1, "--type-aware")

		local js_filetypes = {
			javascript = true,
			typescript = true,
			javascriptreact = true,
			typescriptreact = true,
			svelte = true,
			astro = true,
		}

		local function has_root_config(bufnr, config_files)
			local buffer_path = vim.api.nvim_buf_get_name(bufnr)
			local search_path = buffer_path ~= "" and vim.fs.dirname(buffer_path) or vim.fn.getcwd()
			return vim.fs.find(config_files, { path = search_path, upward = true, type = "file" })[1] ~= nil
		end

		local function get_js_linter(bufnr)
			if has_root_config(bufnr, { "biome.json", "biome.jsonc" }) then
				return "biomejs"
			end
			if
				has_root_config(bufnr, {
					".eslintrc.js",
					".eslintrc.cjs",
					".eslintrc.json",
					".eslintrc.yml",
					".eslintrc",
				})
			then
				return "eslint_d"
			end
			return "oxlint"
		end

		lint.linters_by_ft = {
			markdown = {},
		}

		local function lint_buffer(bufnr)
			if not vim.bo[bufnr].modifiable then
				return
			end

			local filetype = vim.bo[bufnr].filetype
			if js_filetypes[filetype] then
				lint.try_lint({ get_js_linter(bufnr) })
				return
			end

			lint.try_lint()
		end

		-- Create autocommand which carries out the actual linting
		-- on the specified events.
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function(args)
				lint_buffer(args.buf)
			end,
		})
		vim.api.nvim_create_autocmd("User", {
			group = lint_augroup,
			pattern = "KnthLint",
			callback = function(args)
				lint_buffer(args.data and args.data.bufnr or vim.api.nvim_get_current_buf())
			end,
		})
	end,
}
