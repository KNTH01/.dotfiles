-- Mappings

local map_opt = { noremap = true, silent = true }

--Remap for dealing with word wrap
vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Y yank until the end of line
vim.api.nvim_set_keymap("n", "Y", "y$", map_opt)

-- set hlsearch to false
vim.api.nvim_set_keymap("n", "<esc><esc>", "<cmd>nohl<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>h", "<cmd>nohl<CR>", map_opt)

-- :w & :q cmds
vim.api.nvim_set_keymap("n", "<C-s>", "<cmd>w<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>w", "<cmd>w<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>q", "<cmd>q<CR>", map_opt)

-- copy current file path
vim.api.nvim_set_keymap("n", "<leader>cp", '<cmd>let @+ = expand("%")<CR>', map_opt)

-- replace the visual selection without pushing the latter into the register
-- #todo: seems not to work
vim.api.nvim_set_keymap("v", "<leader>p", "_P", map_opt)

-- nvim config
local nvim_config_path = "~/.config/nvim/init.lua"
vim.api.nvim_set_keymap("n", "<leader>vs", "<cmd>source " .. nvim_config_path .. "<cr>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>ve", "<cmd>vsplit " .. nvim_config_path .. "<cr>", map_opt)

-- easier moving of code blocks by keeping selection in visual mode
vim.api.nvim_set_keymap("v", "<", "<gv", map_opt)
vim.api.nvim_set_keymap("v", ">", ">gv", map_opt)

