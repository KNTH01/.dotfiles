local null_ls = require("null-ls")

local sources = {
  null_ls.builtins.formatting.prettier.with({
    filetypes = {
      "javascript",
      "typescript",
      "css",
      "scss",
      "html",
      "json",
      "yaml",
      "markdown",
      "graphql",
      "md",
      "txt",
    },
  }),

  null_ls.builtins.formatting.stylua.with({
    args = { "--indent-width", "2", "--indent-type", "Spaces", "-" },
  }),
}

require("null-ls").config({
  sources = sources,
})

require("lspconfig")["null-ls"].setup({})

-- the duration in there is to stop timeouts on massive files
-- vim.cmd("autocmd BufWritePost * lua vim.lsp.buf.formatting_seq_sync(nil, 7500)")
