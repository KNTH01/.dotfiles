return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        -- web dev
        "html",
        "tsserver",
        "cssls",
        "jsonls",
        "emmet_ls",
        "tailwindcss",
        "graphql",

        -- vue & astro
        "volar",
        "astro",

        -- nix
        -- "rnix",

        -- lua
        "lua_ls",
      },
    })
  end,
}
