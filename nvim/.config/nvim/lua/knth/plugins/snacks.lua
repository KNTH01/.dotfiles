---@class snacks.dashboard.Config
local opts_dashboard = {
	enabled = true,
	sections = {
		{ section = "header" },
		{ section = "keys", gap = 1, padding = 1 },
		{ section = "recent_files", padding = 1 },
		{ section = "startup", padding = 4 },
	},
}

---@class snacks.picker.Config
local opts_picker = {
	prompt = " ",

	win = {
		input = {
			keys = {
				["<C-n>"] = { "history_forward", mode = { "i", "n" } },
				["<C-p>"] = { "history_back", mode = { "i", "n" } },
			},
		},
	},
}

return {
	"folke/snacks.nvim",

	enabled = true,
	priority = 1000,
	lazy = false,

	---@type snacks.Config
	opts = {
		dashboard = opts_dashboard,
		picker = opts_picker,
		bigfile = { enabled = true },
		notifier = { enabled = true },
		scroll = { enabled = true },
		quickfile = { enabled = true },
		statuscolumn = { enabled = false },
		words = { enabled = true },

		styles = {
			notification = {
				wo = { wrap = true }, -- Wrap notifications
			},
		},
	},

	keys = {

		-- Picker
		{
			"<leader>,",
			function()
				Snacks.picker.buffers() -- list des buffers, osef
			end,
			desc = "Buffers",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
		-- Picker - files
		{
			"<leader>ff",
			function()
				Snacks.picker.smart()
			end,
			desc = "smart Find Files",
		},

		-- Picker - grep
		{
			"<leader>fg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Find Grep",
		},
		{
			"<leader><space>",
			function()
				vim.cmd("normal! gg") -- workaround to fix lines picker
				Snacks.picker.lines()
			end,
			desc = "Find Grep",
		},

		-- Toggler
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		{
			"<leader>x",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete Buffer",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>gb",
			function()
				Snacks.git.blame_line()
			end,
			desc = "Git Blame Line",
		},
		{
			"<leader>gB",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Git Browse",
		},
		{
			"<leader>gf",
			function()
				Snacks.lazygit.log_file()
			end,
			desc = "Lazygit Current File History",
		},
		{
			"<leader>gl",
			function()
				Snacks.lazygit.log()
			end,
			desc = "Lazygit Log (cwd)",
		},
		{
			"<leader>cR",
			function()
				Snacks.rename()
			end,
			desc = "Rename File",
		},
		{
			"<c-/>",
			function()
				Snacks.terminal()
			end,
			desc = "Toggle Terminal",
		},
		{
			"<c-_>",
			function()
				Snacks.terminal()
			end,
			desc = "which_key_ignore",
		},
		{
			"]]",
			function()
				Snacks.words.jump(vim.v.count1)
			end,
			desc = "Next Reference",
		},
		{
			"[[",
			function()
				Snacks.words.jump(-vim.v.count1)
			end,
			desc = "Prev Reference",
		},
		{
			"<leader>N",
			desc = "Neovim News",
			function()
				Snacks.win({
					file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
					width = 0.6,
					height = 0.6,
					wo = {
						spell = false,
						wrap = false,
						signcolumn = "yes",
						statuscolumn = " ",
						conceallevel = 3,
					},
				})
			end,
		},
	},

	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- Setup some globals for debugging (lazy-loaded)
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for `:=` command

				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.line_number():map("<leader>ul")
				Snacks.toggle
					.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
					:map("<leader>uc")
				Snacks.toggle.treesitter():map("<leader>uT")
				Snacks.toggle
					.option("background", { off = "light", on = "dark", name = "Dark Background" })
					:map("<leader>ub")
				Snacks.toggle.inlay_hints():map("<leader>ui")
			end,
		})
	end,
}
