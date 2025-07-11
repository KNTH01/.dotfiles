return {
	{
		"neovim/nvim-lspconfig",

		event = { "BufReadPre", "BufNewFile" },

		dependencies = {
			-- cmp
			{ "saghen/blink.cmp" },

			{ "mason-org/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"mason-org/mason-lspconfig.nvim",

			{ "antosha417/nvim-lsp-file-operations", config = true }, -- TODO: what is that??

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} }, -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		},

		config = function()
			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {

				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),

				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gk", vim.lsp.buf.hover, "Show documentation under cursor")
					map("K", vim.lsp.buf.signature_help, "Show signature help")
					map("gl", vim.diagnostic.open_float, "Show line diagnostics")
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

			-- local mason_registry = require("mason-registry")
			-- local vue_language_server_path = ""
			-- if mason_registry.is_installed("vue-language-server") then
			-- 	vue_language_server_path = mason_registry.get_package("vue-language-server"):get_install_path()
			-- 		.. "/node_modules/@vue/language-server"
			-- else
			-- 	print("vue-language-server is not installed via Mason. Please install it first.")
			-- 	-- You can either return here or set a default path
			-- end

			-- Use the stable approach recommended by Mason documentation for Mason 2
			local vue_language_server_path =
				vim.fn.expand("$MASON/packages/vue-language-server/node_modules/@vue/language-server")

			-- Check if the directory exists
			if vim.fn.isdirectory(vue_language_server_path) == 0 then
				print("Warning: Vue language server directory not found at: " .. vue_language_server_path)
				print("Make sure you have installed vue-language-server with Mason")
				-- You could return here or set a fallback path
			end

			local function is_deno_project(bufnr_or_filename)
				-- Use vim.fs.root, handles bufnr or filename
				local root = vim.fs.root(bufnr_or_filename, { "deno.json", "deno.jsonc" })
				local is_deno_project_var = root ~= nil
				return is_deno_project_var
			end

			local servers = {
				-- clangd = {},
				-- gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--

				html = {},
				cssls = {},
				tailwindcss = {},
				rnix = {},
				astro = {},
				jsonls = require("knth.lsp_settings.jsonls"),

				denols = {
					-- Use a root_dir function to conditionally attach denols
					root_dir = function(bufnr, on_dir)
						local is_deno = is_deno_project(bufnr)

						if is_deno then
							on_dir()
						end
					end,

					single_file_support = false,
				},

				vtsls = {
					root_dir = function(bufnr, on_dir)
						local is_deno = is_deno_project(bufnr)

						if not is_deno then
							on_dir()
						end
					end,

					single_file_support = false,

					on_init = function(client)
						-- Format using Prettier
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentFormattingRangeProvider = false
					end,

					settings = {
						vtsls = {
							tsserver = {
								globalPlugins = {
									{
										name = "@vue/typescript-plugin",
										location = vue_language_server_path,
										languages = { "vue" },
										configNamespace = "typescript",
									},
								},
							},
						},
						typescript = {
							inlayHints = {
								-- You can set this to 'all' or 'literals' to enable more hints
								includeInlayParameterNameHints = "literals", -- 'none' | 'literals' | 'all'
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = false,
								includeInlayVariableTypeHints = false,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = false,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								-- You can set this to 'all' or 'literals' to enable more hints
								includeInlayParameterNameHints = "literals", -- 'none' | 'literals' | 'all'
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayVariableTypeHints = false,
								includeInlayFunctionParameterTypeHints = false,
								includeInlayVariableTypeHintsWhenTypeMatchesName = false,
								includeInlayPropertyDeclarationTypeHints = false,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},

					filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
				},


				emmet_ls = {
					filetypes = {
						"html",
						"typescriptreact",
						"javascriptreact",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
					},
				},

				graphql = {
					filetypes = {
						"graphql",
						"gql",
						"svelte",
						"typescriptreact",
						"javascriptreact",
					},
				},

				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run :Mason
			require("mason").setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})

			require("mason-lspconfig").setup({
				-- ensure_installed = ensure_installed,
				ensure_installed = {},
			})

			-- If you need to extend capabilities for all servers
			local blink_cmp_capabilities = require("blink.cmp").get_lsp_capabilities({})

			-- Setup each server with customizations
			for server_name, server_config in pairs(servers) do
        -- folding_capabilities for ufo.nvim
				local folding_capabilities = {
					textDocument = {
						foldingRange = {
							dynamicRegistration = false,
							lineFoldingOnly = true,
						},
					},
				}

				-- Add capabilities
				server_config.capabilities = vim.tbl_deep_extend(
					"force",
					{},
					blink_cmp_capabilities,
					folding_capabilities,
					server_config.capabilities or {}
				)

				vim.lsp.config(server_name, server_config)
				vim.lsp.enable(server_name)
			end

			-- Change the Diagnostic symbols in the sign column (gutter)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
			local text_signs = {}
			local text_highlights = {}

			for type, icon in pairs(signs) do
				local severity = vim.diagnostic.severity[type:upper()]
				if severity then
					text_signs[severity] = icon
					text_highlights[severity] = "DiagnosticSign" .. type
				end
			end

			vim.diagnostic.config({
				signs = {
					text = text_signs,
					texthl = text_highlights,
					numhl = {}, -- Empty table since numhl was set to ""
				},
			})
		end,
	},
}
