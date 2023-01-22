-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require('lsp-zero')

-- use cmp setup instead of lsp.setup_nvim_cmp
lsp.preset('lsp-compe')

-- make sure this servers are installed
-- see :help lsp-zero.ensure_installed()
lsp.ensure_installed({
  'rust_analyzer',
  'tsserver',
  'eslint',
  'sumneko_lua',
})

-- don't initialize this language server
-- we will use rust-tools to setup rust_analyzer
lsp.skip_server_setup({ 'rust_analyzer' })

-- the function below will be executed whenever
-- a language server is attached to a buffer
lsp.on_attach(function(client, bufnr)
  print('Greetings from on_attach', client, bufnr)
end)

-- pass arguments to a language server
-- see :help lsp-zero.configure()
lsp.configure('tsserver', {
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end,
  settings = {
    completions = {
      completeFunctionCalls = true
    }
  }
})

-- share configuration between multiple servers
-- see :help lsp-zero.setup_servers()
lsp.setup_servers({
  'eslint',
  'angularls',
  opts = {
    single_file_support = false,
    on_attach = function(client, bufnr)
      print("I'm doing web dev")
    end
  }
})

-- (Optional) Configure lua language server for neovim
-- see :help lsp-zero.nvim_workspace()
lsp.nvim_workspace()

--
-- setup lsp-zero
--
lsp.setup()
------------

vim.diagnostic.config({
  virtual_text = true,
})

-- initialize rust_analyzer with rust-tools
-- see :help lsp-zero.build_options()
local rust_lsp = lsp.build_options('rust_analyzer', {
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello rust-tools')
  end
})

require('rust-tools').setup({ server = rust_lsp })

--
-- cmp config
--
local cmp = require('cmp')
local cmp_mappings = lsp.defaults.cmp_mappings({
    ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-d>'] = cmp.mapping.scroll_docs(5),
    ['<C-u>'] = cmp.mapping.scroll_docs(-5),
    ["<c-y>"] = cmp.mapping(
      cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      { "i", "c" }
    ),
  -- C-e is to toggle complete by default, use this to C-e abort and C-Space complete
  -- ['<C-e>'] = cmp.mapping.abort(),
  --   ["<c-space>"] = cmp.mapping({
  --     i = cmp.mapping.complete(),
  --     c = function(
  --       _ --[[fallback]]
  --     )
  --       if cmp.visible() then
  --         if not cmp.confirm({ select = true }) then
  --           return
  --         end
  --       else
  --         cmp.complete()
  --       end
  --     end,
  --   }),
})
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil
cmp_mappings['<CR>'] = nil

cmp.setup(
  lsp.defaults.cmp_config({
    mapping = cmp_mappings,
    experimental = {
      ghost_text = true,
      native_menu = false,
    },
  })
)
