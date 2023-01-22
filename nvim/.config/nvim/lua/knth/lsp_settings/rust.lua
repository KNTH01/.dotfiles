local lsp = require('lsp-zero')

-- see :help lsp-zero.build_options()
local rust_lsp = lsp.build_options('rust_analyzer', {
  single_file_support = false,

  on_attach = function()
    print('Hello from rust-tools')
  end,

  settings = {
    ["rust-analyzer"] = {
      lens = {
        enable = true,
      },
      checkOnSave = {
        command = "clippy",
      },
    },
  },
})

return {
  server = rust_lsp,

  -- rust-tools options
  tools = {
    inlay_hints = {
      -- prefix for parameter hints
      parameter_hints_prefix = " ",
      -- prefix for all the other hints (type, chaining)
      other_hints_prefix = " ",
    },
  },

}
