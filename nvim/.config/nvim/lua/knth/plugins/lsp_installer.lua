-- nvim-lsp-installer

local lsp_installer = require("nvim-lsp-installer")

-- Provide settings first!
lsp_installer.settings({
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗",
    },
  },

  -- Limit for the maximum amount of servers to be installed at the same time. Once this limit is reached, any further
  -- servers that are requested to be installed will be put in a queue.
  max_concurrent_installers = 4,
})

local function make_server_ready(attach, capabilities)
  lsp_installer.on_server_ready(function(server)
    local opts = {}
    opts.on_attach = attach
    opts.capabilities = capabilities

    -- for lua
    if server.name == "sumneko_lua" then
      -- only apply these settings for the "sumneko_lua" server
      opts.settings = {
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
      }
    end

    -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
    server:setup(opts)
    vim.cmd([[ do User LspAttachBuffers ]])
  end)
end

local function install_server(server)
  local lsp_installer_servers = require("nvim-lsp-installer.servers")
  local ok, server_analyzer = lsp_installer_servers.get_server(server)
  if ok then
    if not server_analyzer:is_installed() then
      server_analyzer:install(server)
    end
  end
end

-- #todo: refact servers variable to be exported from lua/plugins/nvim_lspconfig.lua
local servers = {
  -- rust
  "rust_analyzer",

  -- lua
  "sumneko_lua",

  -- web dev
  "tsserver",
  "jsonls",
  "vuels",
  "html",
  "cssls",
  "eslint",
}

require("knth.plugins.lsp_config")

make_server_ready(On_attach, Capabilities) -- LSP mappings

-- install the language servers
for _, server in ipairs(servers) do
  install_server(server)
end
