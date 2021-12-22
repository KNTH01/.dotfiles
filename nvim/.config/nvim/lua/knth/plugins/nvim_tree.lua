local present, nvimtree = pcall(require, "nvim-tree")
if not present then
  return
end
local tree_cb = require("nvim-tree.config").nvim_tree_callback

-- Set alias for vim.g.
local g = vim.g

g.nvim_tree_auto_ignore_ft = { "dashboard" } -- Don't open tree on specific fiypes.
g.nvim_tree_quit_on_open = 1 -- closes tree when file's opened.
g.nvim_tree_indent_markers = 1 -- This option shows indent markers when folders are open.
g.nvim_tree_git_hl = 1 -- Will enable file highlight for git attributes (can be used without the icons).
g.nvim_tree_highlight_opened_files = 0 -- Will enable folder and file icon highlight for opened files/directories.
g.nvim_tree_add_trailing = 0 -- Append a trailing slash to folder names. ]]
vim.g.nvim_tree_window_picker_exclude = {
  filetype = { "packer", "vista_kind" },
  buftype = { "terminal" },
}

nvimtree.setup({
  auto_close = true,
  open_on_tab = false,
  update_cwd = true,
  update_to_buf_dir = {
    enable = true,
    auto_open = true,
  },
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  view = {
    width = "20%",
    side = "right",
    mappings = {
      list = {
        { key = "<S-h>", cb = ":call ResizeLeft(3)<CR>" },
        { key = "<C-h>", cb = tree_cb("toggle_dotfiles") },
      },
    },
  },
  filters = {
    -- do not show dotfiles
    dotfiles = false,
    -- ignore these types in listing
    custom = { ".git", "node_modules", ".cache", "__pycache__" },
  },
})

local map_opt = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>r", ":NvimTreeRefresh<CR>", map_opt)
-- vim.api.nvim_set_keymap("n", "<leader>q", ":NvimTreeFindFile<CR>", map_opt)
