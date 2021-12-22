-- Mappings

local map_opt = { noremap = true, silent = true }
local term_opts = { silent = true }

-- alias for keymap fn
local keymap = vim.api.nvim_set_keymap

-- remap space as leader key
keymap("", "<Space>", "<Nop>", map_opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Y yank until the end of line
keymap("n", "Y", "y$", map_opt)

-- set hlsearch to false
keymap("n", "<esc><esc>", "<cmd>nohl<CR>", map_opt)
keymap("n", "<leader>h", "<cmd>nohl<CR>", map_opt)

-- :w & :q cmds
keymap("n", "<C-s>", "<cmd>w<CR>", map_opt)
keymap("n", "<leader>w", "<cmd>w<CR>", map_opt)
keymap("n", "<leader>q", "<cmd>q<CR>", map_opt)

-- copy current file path
keymap("n", "<leader>cp", '<cmd>let @+ = expand("%")<CR>', map_opt)

-- replace the visual selection without pushing the latter into the register
-- #todo: seems not to work
keymap("v", "<leader>p", "_P", map_opt)

-- nvim config
local nvim_config_path = "~/.config/nvim/init.lua"
keymap("n", "<leader>vs", "<cmd>source " .. nvim_config_path .. "<cr>", map_opt)
keymap("n", "<leader>ve", "<cmd>vsplit " .. nvim_config_path .. "<cr>", map_opt)

-- easier moving of code blocks by keeping selection in visual mode
keymap("v", "<", "<gv", map_opt)
keymap("v", ">", ">gv", map_opt)

-- quickfix list navigation
keymap("n", "<C-j>", ":cnext<cr>zz", map_opt)
keymap("n", "<C-k>", ":cprev<cr>zz", map_opt)
