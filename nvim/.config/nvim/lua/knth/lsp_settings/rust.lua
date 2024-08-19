return {
	server = {
		-- standalone file support ; setting it to false may improve startup time
		standalone = true,

		on_attach = function(_client, bufnr)
			vim.keymap.set("n", "K", function()
				vim.cmd.RustLsp({ "hover", "actions" })
			end, { buffer = bufnr })
			vim.keymap.set("n", "<Leader>ca", function()
				vim.cmd.RustLsp("codeAction")
			end, { buffer = bufnr })
			vim.keymap.set("n", "<Leader>J", function()
				vim.cmd.RustLsp("joinLines")
			end, { buffer = bufnr })
			vim.keymap.set("n", "gl", function()
				vim.cmd.RustLsp("renderDiagnostic")
			end, { buffer = bufnr })
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
