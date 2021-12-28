return {
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the 'vim', 'use' global
        globals = { "vim", "use", "require" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
