local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		{
			"L3MON4D3/LuaSnip", -- snippet engine
			version = "2.*",
		},
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", -- useful snippets
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		"onsails/lspkind.nvim", -- vs-code like pictograms
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			snippet = { -- configure how nvim-cmp interacts with snippet engine
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-e>"] = function(_)
					if cmp.visible() then
						cmp.abort()
					else
						cmp.complete()
					end
				end,

				["<c-y>"] = cmp.mapping(
					cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Insert,
						select = true,
					}),
					{ "i", "c" }
				),

				["<C-j>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					elseif has_words_before() then
						cmp.complete()
					else
						fallback()
					end
				end, { "i", "s" }),

				["<C-k>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),

				["<C-l>"] = cmp.mapping(function()
					if luasnip.choice_active() then
						luasnip.change_choice(1)
					end
				end, { "i" }),

				["<C-d>"] = cmp.mapping.scroll_docs(5),
				["<C-u>"] = cmp.mapping.scroll_docs(-5),

				["<Tab>"] = cmp.config.disable,
				["<S-Tab>"] = cmp.config.disable,
				["<CR>"] = cmp.config.disable,
			}),

			-- sources for autocompletion
			sources = cmp.config.sources({
				{ name = "crates" },
				{ name = "nvim_lsp" },
				{ name = "nvim_lua" },
				{ name = "path" }, -- file system paths
				{ name = "luasnip" }, -- snippets
				{ name = "buffer" }, -- text within current buffer
			}),

			-- configure lspkind for vs-code like pictograms in completion menu
			formatting = {
				-- changing the order of fields so the icon is the first
				-- fields = { "menu", "abbr", "kind" },
				format = lspkind.cmp_format({
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
		})
	end,
}

-- --- LuaSnip
-- local ls = require("luasnip")
-- local types = require("luasnip.util.types")
--
-- ls.config.set_config({
-- 	-- This tells LuaSnip to remember to keep around the last snippet.
-- 	-- You can jump back into it even if you move outside of the selection
-- 	history = false,
--
-- 	-- This one is cool cause if you have dynamic snippets, it updates as you type!
-- 	updateevents = "TextChanged,TextChangedI",
--
-- 	-- Autosnippets:
-- 	enable_autosnippets = true,
--
-- 	-- Crazy highlights!!
-- 	-- #vid3
-- 	-- ext_opts = nil,
-- 	ext_opts = {
-- 		[types.choiceNode] = {
-- 			active = {
-- 				virt_text = { { " « ", "NonTest" } },
-- 			},
-- 		},
-- 	},
-- })
