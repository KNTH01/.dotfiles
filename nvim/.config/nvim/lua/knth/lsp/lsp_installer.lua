-- nvim-lsp-installer

local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

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
    local opts = {
      on_attach = attach,
      capabilities = capabilities,
    }

    if server.name == "jsonls" then
      local jsonls_opts = require("knth.lsp.settings.jsonls")
      opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
    end

    if server.name == "sumneko_lua" then
      local sumneko_opts = require("knth.lsp.settings.sumneko_lua")
      opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
    end

    -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
    server:setup(opts)
    vim.cmd([[ do User LspAttachBuffers ]])
  end)
end

-- attach and capabilities from lsp_config
local lsp_handlers = require("knth.lsp.handlers")
make_server_ready(lsp_handlers.on_attach, lsp_handlers.capabilities)

local function install_server(server)
  local lsp_installer_servers = require("nvim-lsp-installer.servers")
  local ok, server_analyzer = lsp_installer_servers.get_server(server)
  if ok then
    if not server_analyzer:is_installed() then
      server_analyzer:install(server)
    end
  end
end

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

-- install the language servers
for _, server in ipairs(servers) do
  install_server(server)
end
