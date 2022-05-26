-- Mappings

--   Modes
--      normal_mode = "n",
--      insert_mode = "i",
--      visual_mode = "v",
--      visual_block_mode = "x",
--      term_mode = "t",
--      command_mode = "c",

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- alias for keymap fn
local keymap = vim.api.nvim_set_keymap

-- remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- NORMAL
--

-- nvim config
local nvim_config_path = "~/.config/nvim/init.lua"
keymap("n", "<leader>vs", "<cmd>source " .. nvim_config_path .. "<cr>", opts)
keymap("n", "<leader>ve", "<cmd>vsplit " .. nvim_config_path .. "<cr>", opts)

-- Better window navigation
-- keymap("n", "<C-h>", "<C-w>h", opts)
-- keymap("n", "<C-j>", "<C-w>j", opts)
-- keymap("n", "<C-k>", "<C-w>k", opts)
-- keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>x", "<cmd>Bdelete<cr>", opts)

-- Remap for dealing with word wrap
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- set hlsearch to false
keymap("n", "<esc><esc>", "<cmd>nohl<CR>", opts)
keymap("n", "<leader>h", "<cmd>nohl<CR>", opts)

-- :w & :q cmds
keymap("n", "<C-s>", "<cmd>w<CR>", opts)
keymap("n", "<leader>w", "<cmd>w<CR>", opts)
keymap("n", "<leader>q", "<cmd>q<CR>", opts)

-- copy current file path
-- @TODO: create a vim command, cf formatting
keymap("n", "<leader>cp", '<cmd>let @+ = expand("%")<CR>', opts)

-- quickfix list navigation
keymap("n", "<C-j>", ":cnext<cr>zz", opts)
keymap("n", "<C-k>", ":cprev<cr>zz", opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==", opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==", opts)


-- VISUAL
--

-- replace the visual selection without pushing the latter into the register
keymap("v", "p", '"_dP', opts)

-- easier moving of code blocks by keeping selection in visual mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)

-- VISUAL BLOCK
--

-- Move text up and down
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)
