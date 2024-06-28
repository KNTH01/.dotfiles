return {
	{
		"neovim/nvim-lspconfig",

		event = { "BufReadPre", "BufNewFile" },

		dependencies = {
			{ "antosha417/nvim-lsp-file-operations", config = true },
			{
				"folke/neodev.nvim",
				opts = {
					--   override = function(root_dir, library)
					--     if root_dir:find("/etc/nixos", 1, true) == 1 then
					--       library.enabled = true
					--       library.plugins = true
					--     end
					--   end,
				},
			},
		},

		config = function()
			local util = require("lspconfig.util")

			local function get_typescript_server_path(root_dir)
				local global_ts = "/home/knth/.nix-profile/lib/node_modules/typescript/lib"
				--
				-- Alternative location if installed as root:
				-- local global_ts = '/usr/local/lib/node_modules/typescript/lib'

				local found_ts = ""
				local function check_dir(path)
					found_ts = util.path.join(path, "node_modules", "typescript", "lib")
					if util.path.exists(found_ts) then
						return path
					end
				end
				if util.search_ancestors(root_dir, check_dir) then
					return found_ts
				else
					return global_ts
				end
			end

			-- import lspconfig plugin
			local lspconfig = require("lspconfig")

			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			local lsp_attach = require("knth.lsp_settings.lsp-attach").attach

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = lsp_attach,
			})

			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- Make sure these tools are configured in nix home-manager
			local lsps = {
				-- nix
				"nixd",

				-- lua
				"lua_ls",

				-- web dev
				"html",
				"tsserver",
				"cssls",
				"jsonls",

				-- vue & astro
				"volar",
				"astro",

				-- misc
				"eslint",
				"emmet_language_server",
				"tailwindcss",
				"graphql",
			}

			for _, server in ipairs(lsps) do
				local opts = {
					capabilities = capabilities,
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

				if server == "volar" then
					opts = vim.tbl_extend("force", opts, {
						on_new_config = function(new_config, new_root_dir)
							new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
						end,
					})
				end

				if server == "graphql" then
					opts.filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" }
				end

				if server == "emmet_language_server" then
					opts.filetypes =
						{ "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" }
				end

				lspconfig[server].setup(opts)
			end

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
