local root = vim.fn.getcwd()

local function read(rel)
  return table.concat(vim.fn.readfile(root .. "/" .. rel), "\n")
end

local lsp = read("lua/knth/plugins/lsp/lspconfig.lua")

assert(lsp:find("vtsls = {", 1, true), "phase 1 should keep vtsls")
assert(lsp:find("denols = {", 1, true), "phase 1 should keep denols")
assert(lsp:find("@effect/language-service", 1, true), "phase 1 must keep effect support")
assert(not lsp:find("tsgo = {", 1, true), "phase 1 must not switch to tsgo yet")
assert(not lsp:find("vue_language_server_path", 1, true), "remove vue language server path")
assert(not lsp:find("@vue/typescript-plugin", 1, true), "remove vue typescript plugin")
assert(not lsp:find('filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }', 1, true), "remove vue from vtsls filetypes")
assert(not lsp:find("vue_ls = {", 1, true), "remove vue_ls config")

print("phase1_no_vue_lsp: ok")
