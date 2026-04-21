return {
	"saghen/blink.cmp",

	dependencies = {
		-- nvim-lspconfig provides the server presets (cmd, root_markers, filetypes)
		-- via runtimepath/lsp/*.lua. Neovim 0.12 has the native APIs, but not the presets.
		"neovim/nvim-lspconfig",
		{ "mason-org/mason.nvim", config = true },
		{ "j-hui/fidget.nvim", opts = {} },
	},

	config = function()
		-- User commands to replace LspInfo/LspRestart/LspLog removed in 0.12
		vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {})
		vim.api.nvim_create_user_command("LspRestart", function(info)
			vim.api.nvim_cmd({
				cmd = "lsp",
				args = vim.list_extend({ "restart" }, info.fargs),
				bang = info.bang,
			}, {})
		end, {
			nargs = "?",
			bang = true,
			complete = function()
				return vim.iter(vim.lsp.get_clients({ bufnr = 0 }))
					:map(function(client)
						return client.name
					end)
					:totable()
			end,
		})
		vim.api.nvim_create_user_command("LspLog", function()
			vim.cmd.edit(vim.lsp.log.get_filename())
		end, {})

		-- Mappings LSP via LspAttach
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("knth-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Native 0.12 mappings already present: K (hover), grn (rename),
				-- gra (code action), grr (references), gri (implementation), gO (document symbols).
				-- Keep only the user custom mappings:
				map("gl", vim.diagnostic.open_float, "Show line diagnostics")
				map("gK", vim.lsp.buf.signature_help, "Show signature help")
			end,
		})

		local blink_cmp_capabilities = require("blink.cmp").get_lsp_capabilities({})

		local function is_deno_project(bufnr_or_filename)
			local root = vim.fs.root(bufnr_or_filename, { "deno.json", "deno.jsonc" })
			return root ~= nil
		end

		local function get_effect_ls_path(root_dir)
			if not root_dir then return nil end

			local effect_ls_package = vim.fs.find(
				"node_modules/@effect/language-service/package.json",
				{ upward = true, path = root_dir, type = "file" }
			)[1]

			if not effect_ls_package then return nil end
			return vim.fs.dirname(effect_ls_package)
		end

		local function get_effect_ls_plugin(root_dir)
			local effect_ls_path = get_effect_ls_path(root_dir)
			if not effect_ls_path then return {} end

			return {
				{
					name = "@effect/language-service",
					location = effect_ls_path,
					languages = { "typescript" },
					configNamespace = "typescript",
				},
			}
		end

		local servers = {
			html = {},
			cssls = {},
			tailwindcss = {},
			rnix = {},
			astro = {},
			jsonls = require("knth.lsp_settings.jsonls"),

			denols = {
				root_dir = function(bufnr, on_dir)
					if is_deno_project(bufnr) then on_dir() end
				end,
				single_file_support = false,
			},

			vtsls = {
				root_dir = function(bufnr, on_dir)
					if not is_deno_project(bufnr) then on_dir() end
				end,
				single_file_support = false,
				on_new_config = function(new_config, new_root_dir)
					new_config.settings = new_config.settings or {}
					new_config.settings.vtsls = new_config.settings.vtsls or {}
					new_config.settings.vtsls.tsserver = new_config.settings.vtsls.tsserver or {}
					new_config.settings.vtsls.tsserver.globalPlugins = get_effect_ls_plugin(new_root_dir)
				end,
				on_init = function(client)
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentFormattingRangeProvider = false
				end,
				settings = {
					vtsls = {
						tsserver = {
							globalPlugins = {},
						},
					},
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "literals",
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
							includeInlayParameterNameHints = "literals",
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
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
			},

			emmet_ls = {
				filetypes = {
					"html", "typescriptreact", "javascriptreact",
					"css", "sass", "scss", "less", "svelte",
				},
			},

			graphql = {
				filetypes = {
					"graphql", "gql", "svelte", "typescriptreact", "javascriptreact",
				},
			},

			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
					},
				},
			},
		}

		for server_name, server_config in pairs(servers) do
			server_config.capabilities = vim.tbl_deep_extend(
				"force",
				{},
				blink_cmp_capabilities,
				server_config.capabilities or {}
			)
			vim.lsp.config(server_name, server_config)
			vim.lsp.enable(server_name)
		end

		-- Signs diagnostics
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
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
				numhl = {},
			},
		})
	end,
}
