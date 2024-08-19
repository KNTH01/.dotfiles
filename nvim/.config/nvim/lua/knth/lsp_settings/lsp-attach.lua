return {
	attach = function(evt)
		local keymap = vim.keymap
		local opts = { noremap = true, silent = true, buffer = evt.buf }

		-- LSP custom bindings
		opts.desc = "Show LSP definitions"
		keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")

		opts.desc = "Go to declaration"
		keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

		opts.desc = "Show LSP references"
		keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts) -- keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>")

		opts.desc = "Show LSP implementations"
		keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>")

		opts.desc = "Show LSP type definitions"
		keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>")

		opts.desc = "See available code actions"
		keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

		opts.desc = "Smart rename"
		keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

		opts.desc = "Show documentation for what is under cursor"
		keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

		opts.desc = "Show signature help"
		keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, opts)

		opts.desc = "Find symbols"
		keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", opts)

		-- Diagnostics
		opts.desc = "Show buffer diagnostics"
		keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file
		keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
		keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<cr>")

		opts.desc = "Show line diagnostics"
		keymap.set("n", "gl", vim.diagnostic.open_float, opts)

		opts.desc = "Go to previous diagnostic"
		keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		keymap.set("n", "g[", vim.diagnostic.goto_prev, opts)

		opts.desc = "Go to next diagnostic"
		keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
		keymap.set("n", "g]", vim.diagnostic.goto_next, opts)

		-- inlay hints toggle
    opts.desc = "Toggle inlay hints"
		keymap.set("n", "<leader>i", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, opts)

		-- More stuff
		keymap.set("n", "<leader>be", "<cmd>EslintFixAll<cr>", opts)

		opts.desc = "Restart LSP"
		keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
	end,
}
