--
-- My nvim config
--

---------------❰ Leader Mapping ❱---------------
-- remap space as leader key
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

---------------❰ Load/Source Configs ❱---------------
-- plugin config to improve start-up time.
-- it should be always on top on init.lua file
-- impatient needs to be setup before any other lua plugin is loaded
require("impatient")

-- Easily speed up your neovim startup time!
-- can be removed after upgrading to neovim v0.6
vim.g.did_load_filetypes = 1

require("knth.configs")
require("knth.mappings")
require("knth.plugins")
