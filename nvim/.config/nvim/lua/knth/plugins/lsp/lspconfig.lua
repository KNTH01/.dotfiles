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
      }
    },

    config = function()
      -- import lspconfig plugin
      local lspconfig = require("lspconfig")

      -- import cmp-nvim-lsp plugin
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local on_attach = require("knth.lsp_settings.on-attach").on_attach

      -- used to enable autocompletion (assign to every lsp server config)
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Make sure these tools are configured in nix home-manager
      local lsps =
      {
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
        "emmet_ls",
        "tailwindcss",
        "graphql",
      }

      for _, server in ipairs(lsps) do
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

        if server == "graphql" then
          opts.filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" }
        end

        if server == "emmet_ls" then
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
    'mrcjkb/rustaceanvim',
    version = '^4', -- Recommended
    ft = { 'rust' },

    config = function()
      print("rustaceanvim config")

      local my_config = require("knth.lsp_settings.rust")

      vim.g.rustaceanvim = {
        server = my_config.server
      }
    end,
  },
}
