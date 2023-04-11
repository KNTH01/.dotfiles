return
{
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v1.x",
    dependencies = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- null-ls
      { "jose-elias-alvarez/null-ls.nvim" },
      { "jay-babu/mason-null-ls.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lua" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "rafamadriz/friendly-snippets" },
    },
    config = function()
      -- Learn the keybindings, see :help lsp-zero-keybindings
      -- Learn to configure LSP servers, see :help lsp-zero-api-showcase
      local lsp = require('lsp-zero')

      -- use cmp setup instead of lsp.setup_nvim_cmp
      lsp.preset('lsp-compe')

      -- make sure this servers are installed
      -- see :help lsp-zero.ensure_installed()
      lsp.ensure_installed({
        -- rust
        "rust_analyzer",

        -- lua
        "sumneko_lua",

        -- web dev
        "tsserver",
        "jsonls",
        "volar",
        "html",
        "cssls",
        "eslint",
        "tailwindcss",
      })

      -- configure jsonls
      lsp.configure('jsonls', require("knth.lsp_settings.jsonls"))

      lsp.setup_servers({
        'volar',
        'tsserver',
        opts = {
          on_init = function(client)
            -- Format using Prettier
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentFormattingRangeProvider = false
          end,
        }
      })

      -- the function below will be executed whenever
      -- a language server is attached to a buffer
      lsp.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }

        -- LSP actions
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
        vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
        vim.keymap.set('n', '<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
        vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>')
        vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>')
        vim.keymap.set('x', '<leader>ca', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')
        -- Diagnostics
        vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
        vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
        vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<cr>')
        -- More stuff
        vim.keymap.set("n", "<leader>fs", '<cmd>Telescope lsp_document_symbols<cr>', opts)
        vim.keymap.set("n", "<leader>fm", '<cmd>LspZeroFormat<cr>', opts)
        vim.keymap.set("n", "<leader>be", '<cmd>EslintFixAll<cr>', opts)
      end)

      -- don't initialize this language server
      -- we will use rust-tools to setup rust_analyzer
      lsp.skip_server_setup({ 'rust_analyzer' })

      -- (Optional) Configure lua language server for neovim
      -- see :help lsp-zero.nvim_workspace()
      lsp.nvim_workspace()

      --
      -- setup lsp-zero
      lsp.setup()

      -- initialize rust_analyzer with rust-tools
      require('rust-tools').setup(require("knth.lsp_settings.rust"))

      --
      -- After LSP setup
      --

      -- enable virtual_text for diagnostic
      vim.diagnostic.config({
        virtual_text = true,
      })

      --
      -- cmp config
      local cmp = require('cmp')
      local cmp_mappings = lsp.defaults.cmp_mappings({
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ['<C-d>'] = cmp.mapping.scroll_docs(5),
        ['<C-u>'] = cmp.mapping.scroll_docs(-5),
        ["<c-y>"] = cmp.mapping(
          cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          { "i", "c" }
        ),
        -- C-e is to toggle complete by default, use this to C-e abort and C-Space complete
        -- ['<C-e>'] = cmp.mapping.abort(),
        --   ["<c-space>"] = cmp.mapping({
        --     i = cmp.mapping.complete(),
        --     c = function(
        --       _ --[[fallback]]
        --     )
        --       if cmp.visible() then
        --         if not cmp.confirm({ select = true }) then
        --           return
        --         end
        --       else
        --         cmp.complete()
        --       end
        --     end,
        --   }),
      })
      cmp_mappings['<Tab>'] = nil
      cmp_mappings['<S-Tab>'] = nil
      cmp_mappings['<CR>'] = nil

      cmp.setup(
        lsp.defaults.cmp_config({
          mapping = cmp_mappings,
          experimental = {
            ghost_text = true,
            native_menu = false,
          },
        })
      )

      --
      -- Configure Prettier to format code
      --
      local null_ls = require('null-ls')

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettierd,
        }
      })

      -- See mason-null-ls.nvim's documentation for more details:
      -- https://github.com/jay-babu/mason-null-ls.nvim#setup
      require('mason-null-ls').setup({
        ensure_installed = nil,
        automatic_installation = true,
        automatic_setup = false,
      })
    end
  },

  -- Rust LSP
  "simrat39/rust-tools.nvim",
}
