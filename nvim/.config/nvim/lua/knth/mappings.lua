-- Mappings

--   Modes
--      normal_mode = "n",
--      insert_mode = "i",
--      visual_mode = "v",
--      visual_block_mode = "x",
--      term_mode = "t",
--      command_mode = "c",

-- alias for keymap fn
local keymap = vim.keymap
-- local keymap = vim.api.nvim_set_keymap

-- remap space as leader key
keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- NORMAL
--

-- nvim config
local nvim_config_path = "~/.config/nvim/init.lua"
keymap.set("n", "<leader>vs", "<cmd>source " .. nvim_config_path .. "<cr>")
keymap.set("n", "<leader>ve", "<cmd>vsplit " .. nvim_config_path .. "<cr>")

-- put the operation into the void register
keymap.set("n", "x", '"_x')

-- increment / decrement numbers
keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- Better window navigation
vim.keymap.set("n", "J", "mzJ`z") -- do not move the cursor while joining line
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- down
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- up
vim.keymap.set("n", "n", "nzzzv") -- search
vim.keymap.set("n", "N", "Nzzzv") -- search

-- setup by christoomey/vim-tmux-navigator plugin
-- keymap.set("n", "<C-h>", "<C-w>h")
-- keymap.set("n", "<C-j>", "<C-w>j")
-- keymap.set("n", "<C-k>", "<C-w>k")
-- keymap.set("n", "<C-l>", "<C-w>l")
keymap.set("n", "<leader>sv", "<C-w>v")
keymap.set("n", "<leader>sh", "<C-w>s")

-- Resize with arrows
keymap.set("n", "<C-Up>", ":resize +2<CR>")
keymap.set("n", "<C-Down>", ":resize -2<CR>")
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- Navigate buffers
keymap.set("n", "<S-l>", ":bnext<CR>")
keymap.set("n", "<S-h>", ":bprevious<CR>")
keymap.set("n", "<leader>x", "<cmd>Bdelete<cr>")

-- Remap for dealing with word wrap
vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- set hlsearch to false
keymap.set("n", "<esc><esc>", "<cmd>nohl<CR>")
keymap.set("n", "<leader>h", "<cmd>nohl<CR>")

-- :w & :q cmds
keymap.set("n", "<C-s>", "<cmd>w<CR>")
keymap.set("n", "<leader>w", "<cmd>w<CR>")
keymap.set("n", "<leader>q", "<cmd>q<CR>")

-- quickfix list navigation
keymap.set("n", "<C-j>", ":cnext<cr>zz")
keymap.set("n", "<C-k>", ":cprev<cr>zz")

-- Move text up and down
keymap.set("n", "<A-j>", "<Esc>:m .+1<CR>==")
keymap.set("n", "<A-k>", "<Esc>:m .-2<CR>==")

-- VISUAL
--

-- replace the visual selection without pushing the latter into the register
keymap.set("v", "p", '"_dP')

-- easier moving of code blocks by keeping selection in visual mode
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Move text up and down
keymap.set("v", "<A-j>", ":m .+1<CR>==")
keymap.set("v", "<A-k>", ":m .-2<CR>==")

-- VISUAL BLOCK
--

-- Move text up and down
keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv")
keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv")


-- MISC
keymap.set("n", "<leader>cp", '<cmd>let @+ = expand("%")<CR>') -- copy current file path
-- keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
