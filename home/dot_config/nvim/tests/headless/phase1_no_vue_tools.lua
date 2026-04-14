local root = vim.fn.getcwd()

local function read(rel)
  return table.concat(vim.fn.readfile(root .. "/" .. rel), "\n")
end

local conform = read("lua/knth/plugins/lsp/conform.lua")
assert(not conform:find('vue = { js_formatter }', 1, true), "remove vue formatter mapping")

local lint = read("lua/knth/plugins/lsp/nvim-lint.lua")
assert(not lint:find('vue = { js_linter }', 1, true), "remove vue lint mapping")

local logsitter = read("lua/knth/plugins/logsitter.lua")
assert(not logsitter:find('{ "vue", "astro", "svelte" }', 1, true), "remove vue logsitter mapping")

print("phase1_no_vue_tools: ok")
