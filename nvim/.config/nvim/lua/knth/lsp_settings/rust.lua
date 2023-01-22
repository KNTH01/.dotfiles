return {
  single_file_support = false,

  server = {
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
  },

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
