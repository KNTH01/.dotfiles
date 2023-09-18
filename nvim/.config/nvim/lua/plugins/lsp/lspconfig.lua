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

      local on_attach = require("knth.lsp_settings._on_attach").on_attach

      -- used to enable autocompletion (assign to every lsp server config)
      local capabilities = cmp_nvim_lsp.default_capabilities()

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

        lspconfig[server].setup(opts)

        ::continue::
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
    -- Rust LSP
    "simrat39/rust-tools.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      local rt = require("rust-tools")
      -- fix on_attach that doesn't work!
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
