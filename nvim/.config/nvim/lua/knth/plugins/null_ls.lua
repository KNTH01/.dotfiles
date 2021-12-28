local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

-- code action sources
local code_actions = null_ls.builtins.code_actions

local sources = {
  require("null-ls.helpers").conditional(function(utils)
    if utils.root_has_file(".eslintrc.js") or utils.root_has_file(".eslintrc") then
      return formatting.eslint_d
    else
      return formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } })
    end
  end),

  formatting.shfmt,
  formatting.stylua.with({ args = { "--indent-width", "2", "--indent-type", "Spaces", "-" } }),
  formatting.codespell,

  diagnostics.eslint_d,
  code_actions.gitsigns,
}

lsp_handlers = require("knth.lsp.handlers")

null_ls.setup({
  debug = false,
  sources = sources,

  on_attach = lsp_handlers.on_attach,
  capabilities = lsp_handlers.capabilities,
})
