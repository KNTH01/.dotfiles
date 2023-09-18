return {
	{

		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "antosha417/nvim-lsp-file-operations", config = true },
		},
		config = function()
			-- import lspconfig plugin
			local lspconfig = require("lspconfig")
			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			local on_attach = function(_, bufnr)
				local keymap = vim.keymap -- for conciseness
				local opts = { noremap = true, silent = true }

				opts.buffer = bufnr

				-- LSP custom bindings
				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP references"
				keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>")

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>")

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection
				keymap.set("x", "<leader>ca", vim.lsp.buf.range_code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Show signature help"
				keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts)

				opts.desc = "Find symbols"
				keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", opts)

				-- Diagnostics
				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file
				keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
				keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<cr>")

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				keymap.set("n", "g[", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				keymap.set("n", "g]", vim.diagnostic.goto_next, opts)

				-- More stuff
				keymap.set("n", "<leader>be", "<cmd>EslintFixAll<cr>", opts)

				opts.desc = "Format buffer"
				keymap.set("n", "<leader>fm", function()
					print("hey")
					vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
				end, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end

			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Change the Diagnostic symbols in the sign column (gutter)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end

			for _, server in ipairs(require("knth.lsp_settings._ensure_installed")) do
				local opts = {
					capabilities = capabilities,
					on_attach = on_attach,
				}

				if server == "jsonls" then
					opts = vim.tbl_deep_extend("force", opts, require("knth.lsp_settings.jsonls"))
				end

				if server == "volar" or server == "tsserver" then
					opts = vim.tbl_extend("force", opts, {
						on_init = function(client)
							-- Format using Prettier
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentFormattingRangeProvider = false
						end,
					})
				end

				if server == "rust_analyzer" then
					-- skip setting up rust_analyzer because we will setup below using rust-tools
					goto continue
				end

				if server == "lua_ls" then
					opts = vim.tbl_deep_extend("force", opts, require("knth.lsp_settings.lua_ls"))
				end

				if server == "graphql" then
					opts.filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" }
				end

				if server == "emmet_ls" then
					opts.filetypes =
						{ "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" }
				end

				-- configure svelte server if one day i'll need it
				-- lspconfig["svelte"].setup({
				--   capabilities = capabilities,
				--   on_attach = function(client, bufnr)
				--     on_attach(client, bufnr)
				--
				--     vim.api.nvim_create_autocmd("BufWritePost", {
				--       pattern = { "*.js", "*.ts" },
				--       callback = function(ctx)
				--         if client.name == "svelte" then
				--           client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
				--         end
				--       end,
				--     })
				--   end,
				-- })

				print(server)
				lspconfig[server].setup(opts)

				::continue::
			end
		end,
	},

	{
		-- Rust LSP
		"simrat39/rust-tools.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		config = function()
			local rt = require("rust-tools")
			rt.setup(require("knth.lsp_settings.rust"))
		end,
	},
}

-- --- LuaSnip
-- local ls = require("luasnip")
-- local types = require("luasnip.util.types")
--
-- ls.config.set_config({
-- 	-- This tells LuaSnip to remember to keep around the last snippet.
-- 	-- You can jump back into it even if you move outside of the selection
-- 	history = false,
--
-- 	-- This one is cool cause if you have dynamic snippets, it updates as you type!
-- 	updateevents = "TextChanged,TextChangedI",
--
-- 	-- Autosnippets:
-- 	enable_autosnippets = true,
--
-- 	-- Crazy highlights!!
-- 	-- #vid3
-- 	-- ext_opts = nil,
-- 	ext_opts = {
-- 		[types.choiceNode] = {
-- 			active = {
-- 				virt_text = { { " « ", "NonTest" } },
-- 			},
-- 		},
-- 	},
-- })
--
-- -- vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
-- -- vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
-- -- vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(-1) end, { silent = true })
-- -- vim.keymap.set({ "i", "s" }, "<C-E>", function()
-- --   if ls.choice_active() then
-- --     ls.change_choice(1)
-- --   end
-- -- end, { silent = true })
--
-- --- END luasnip
--
-- cmp.setup(lsp_zero.defaults.cmp_config({
-- 	mapping = cmp_mappings,
-- 	experimental = {
-- 		ghost_text = true,
-- 		native_menu = false,
-- 	},
--
-- 	-- unshift `crates` in the sources
-- 	sources = {
-- 		{ name = "crates" },
-- 		unpack(lsp_zero.defaults.cmp_config().sources),
-- 	},
-- }))
