-- nvim-lsp-installer

local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
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
  "tailwindcss",
}

local settings = {
  ensure_installed = servers,
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
}

-- Provide settings first!
lsp_installer.setup(settings)

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local lsp_handlers = require("knth.lsp.handlers")

local opts = {}

for _, server in pairs(servers) do
  opts = {
    on_attach = lsp_handlers.on_attach,
    capabilities = lsp_handlers.capabilities,
  }

  if server == "jsonls" then
    local jsonls_opts = require("knth.lsp.settings.jsonls")
    opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
  end

  if server == "sumneko_lua" then
    local sumneko_opts = require("knth.lsp.settings.sumneko_lua")
    opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
  end

  if server == "rust_analyzer" then
    local rust_opts = require("knth.lsp.settings.rust")

    local rust_tools_status_ok, rust_tools = pcall(require, "rust-tools")
    if not rust_tools_status_ok then
      return
    end

    rust_tools.setup(rust_opts)
    goto continue
  end

  lspconfig[server].setup(opts)
  ::continue::
end
