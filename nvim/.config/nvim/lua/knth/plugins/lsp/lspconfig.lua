return {
	{
		"neovim/nvim-lspconfig",

		event = { "BufReadPre", "BufNewFile" },

		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

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

					local telescope_builtin = require("telescope.builtin")

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", telescope_builtin.lsp_definitions, "[g]oto [d]efinition")

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Find references for the word under your cursor.
					map("gr", telescope_builtin.lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", telescope_builtin.lsp_implementations, "[G]oto [I]mplementation") -- TODO: or "gi" ??

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>D", telescope_builtin.lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", telescope_builtin.lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map("<leader>ws", telescope_builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					map("gk", vim.lsp.buf.hover, "Show documentation under cursor")
					map("K", vim.lsp.buf.signature_help, "Show signature help")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>i", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "Toggle [I]nlay Hints")
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local util = require("lspconfig.util")

			local function get_typescript_server_path(root_dir)
				local global_ts = "/home/knth/.local/share/pnpm/global/5/node_modules/typescript/lib"
				local found_ts = ""

				local function check_dir(path)
					found_ts = util.path.join(path, "node_modules", "typescript", "lib")
					if util.path.exists(found_ts) then
						return found_ts
					end
				end

				if util.search_ancestors(root_dir, check_dir) then
					return found_ts
				else
					return global_ts
				end
			end

			local lspconfig = require("lspconfig")

			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup_handlers({

				-- default handler for installed servers
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = capabilities,
					})
				end,

				["jsonls"] = function()
					local opts = {
						capabilities = capabilities,
					}

					vim.tbl_deep_extend("force", opts, require("knth.lsp_settings.jsonls"))

					lspconfig["jsonls"].setup(opts)
				end,

				["volar"] = function()
					lspconfig["volar"].setup({
						capabilities = capabilities,
						on_init = function(client)
							-- Format using Prettier
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentFormattingRangeProvider = false
						end,
						filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
						-- init_options = {
						-- 	vue = {
						-- 		hybridMode = false,
						-- 	},
						-- },
						on_new_config = function(new_config, new_root_dir)
							new_config.init_options = {
								typescript = {
									tsdk = get_typescript_server_path(new_root_dir),
								},
								vue = {
									hybridMode = false,
								},
							}
						end,
						settings = {
							typescript = {
								inlayHints = {
									enumMemberValues = {
										enabled = true,
									},
									functionLikeReturnTypes = {
										enabled = true,
									},
									propertyDeclarationTypes = {
										enabled = true,
									},
									parameterTypes = {
										enabled = true,
										suppressWhenArgumentMatchesName = true,
									},
									variableTypes = {
										enabled = true,
									},
								},
							},
						},
					})
				end,

				["ts_ls"] = function()
					-- local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
					-- local volar_path = mason_packages .. "/vue-language-server/node_modules/@vue/language-server"

					lspconfig["ts_ls"].setup({
						capabilities = capabilities,
						on_init = function(client)
							-- Format using Prettier
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentFormattingRangeProvider = false
						end,

						settings = {
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

						-- init_options = {
						-- plugins = {
						-- 	{
						-- 		name = "@vue/typescript-plugin",
						-- 		location = volar_path,
						-- 		languages = { "vue" },
						-- 	},
						-- },
						-- },
					})
				end,

				["graphql"] = function()
					lspconfig["graphql"].setup({
						capabilities = capabilities,
						filetypes = {
							"graphql",
							"gql",
							"svelte",
							"typescriptreact",
							"javascriptreact",
						},
					})
				end,

				["emmet_ls"] = function()
					lspconfig["emmet_ls"].setup({
						capabilities = capabilities,
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
					})
				end,

				["lua_ls"] = function()
					lspconfig["lua_ls"].setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								-- make the language server recognize "vim" global
								diagnostics = {
									globals = { "vim" },
								},
								completion = {
									callSnippet = "Replace",
								},
							},
						},
					})
				end,
			})

			-- Change the Diagnostic symbols in the sign column (gutter)
			local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }

			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
			end
		end,
	},

	{
		"mrcjkb/rustaceanvim",
		version = "^4", -- Recommended
		ft = { "rust" },

		config = function()
			local my_config = require("knth.lsp_settings.rust")

			vim.g.rustaceanvim = {
				server = my_config.server,
			}
		end,
	},
}
