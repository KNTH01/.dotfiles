return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },

	config = function()
		local harpoon = require("harpoon")

		-- REQUIRED
		harpoon:setup({})
		-- REQUIRED

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Harpoon [a]dd" })

		vim.keymap.set("n", "<leader>J", function()
			harpoon:list():add()
		end, { desc = "Harpoon Add" })

		vim.keymap.set("n", "<leader>j", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon List" })

		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon to file 1" })

		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon to file 2" })

		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon to file 3" })

		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon to file 4" })

		-- Toggle previous & next buffers stored within Harpoon list
		-- vim.keymap.set("n", "<leader>i", function()
		-- 	harpoon:list():prev()
		-- end)
		-- vim.keymap.set("n", "<leader>o", function()
		-- 	harpoon:list():next()
		-- end)
	end,
}
