return {
  -- Snippets
  -- { "L3MON4D3/LuaSnip" },
  -- { "rafamadriz/friendly-snippets" },


  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",           -- source for text in buffer
    "hrsh7th/cmp-path",             -- source for file system paths
    "L3MON4D3/LuaSnip",             -- snippet engine
    "saadparwaiz1/cmp_luasnip",     -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim",         -- vs-code like pictograms
    -- checking this?
    -- "hrsh7th/cmp-nvim-lsp", // importedd in p/l/lspconfig.lua
    -- "hrsh7th/cmp-nvim-lua",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,preview,noselect",
      },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-d>"] = cmp.mapping.scroll_docs(5),
        ["<C-u>"] = cmp.mapping.scroll_docs(-5),
        ["<c-y>"] = cmp.mapping(
          cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          { "i", "c" }
        ),
        ["<Tab>"] = cmp.config.disable,
        ["<S-Tab>"] = cmp.config.disable,
        ["<CR>"] = cmp.config.disable,

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
      }),

      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- snippets
        { name = "buffer" },  -- text within current buffer
        { name = "path" },    -- file system paths
      }),

      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
        }),
      },
    })
  end,
}
