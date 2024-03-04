-- local rt = require("rust-tools")
-- local mason_registry = require("mason-registry")
-- local codelldb = mason_registry.get_package("codelldb")
-- local extension_path = codelldb:get_install_path() .. "/extension/"
-- local codelldb_path = extension_path .. "adapter/codelldb"
-- local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"

-- hardcode port because of this following error: Couldn't connect to 127.0.0.1:${port}: ECONNREFUSED
-- local rt_codelldb_adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
-- rt_codelldb_adapter.port = 13000
-- then i got: Couldn't connect to 127.0.0.1:13000: ECONNREFUSED lol



return {
  server = {
    -- standalone file support ; setting it to false may improve startup time
    standalone = true,

    on_attach = function(client, bufnr)
      require("knth.lsp_settings._on_attach").on_attach(client, bufnr)

      -- vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr })
      -- vim.keymap.set("n", "J", rt.join_lines.join_lines, { buffer = bufnr })
      --
      -- vim.keymap.set("n", "<leader>ie", rt.inlay_hints.set, { buffer = bufnr })
      -- vim.keymap.set("n", "<leader>id", rt.inlay_hints.unset, { buffer = bufnr })
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
    hover_actions = {
      auto_focus = true,
    },
    inlay_hints = {
      -- prefix for parameter hints
      parameter_hints_prefix = " ",
      -- prefix for all the other hints (type, chaining)
      other_hints_prefix = " ",
    },
  },

  dap = {
    -- adapter = rt_codelldb_adapter
  },
}
