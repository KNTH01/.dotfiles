local mason_status, mason = pcall(require, "mason")
if not mason_status then
  return
end

local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status then
  return
end

local mason_null_ls_status, mason_null_ls = pcall(require, "mason-null-ls")
if not mason_null_ls_status then
	return
end

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local lsp_handlers = require("knth.lsp.handlers")

local servers = {
    -- rust
    "rust_analyzer",

    -- lua
    "sumneko_lua",

    -- web dev
    "tsserver",
    "jsonls",
    "volar",
    "html",
    "cssls",
    "eslint",
    "tailwindcss",
}

mason.setup()
mason_lspconfig.setup({
  ensure_installed = servers,
})


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

  if server == "volar" then
    opts = vim.tbl_deep_extend("force", {
      init_options = {
        typescript = {
          -- @TODO: find a proper solution
          tsdk = "/home/knth/code/livestorm-app/node_modules/typescript/lib",
        },
      },
    }, opts)
  end

  lspconfig[server].setup(opts)
  ::continue::
end

mason_null_ls.setup({
	-- list of formatters & linters for mason to install
	ensure_installed = {
		"prettier", -- ts/js formatter
		"stylua", -- lua formatter
		"eslint_d", -- ts/js linter
	},
	-- auto-install configured formatters & linters (with null-ls)
	automatic_installation = true,
})
