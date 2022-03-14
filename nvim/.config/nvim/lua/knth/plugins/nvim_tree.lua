local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

local config_status_ok, nvim_tree_config = pcall(require, "nvim-tree.config")
if not config_status_ok then
  return
end

local tree_cb = nvim_tree_config.nvim_tree_callback

vim.g.nvim_tree_icons = {
  default = "",
  symlink = "",
  git = {
    unstaged = "",
    staged = "S",
    unmerged = "",
    renamed = "➜",
    deleted = "",
    untracked = "U",
    ignored = "◌",
  },
  folder = {
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = "",
  },
}

vim.g.nvim_tree_auto_ignore_ft = { "dashboard" } -- Don't open tree on specific fiypes.
-- vim.g.nvim_tree_quit_on_open = true -- closes tree when file's opened.
vim.g.nvim_tree_indent_markers = 1 -- This option shows indent markers when folders are open.
vim.g.nvim_tree_git_hl = 1 -- Will enable file highlight for git attributes (can be used without the icons).
vim.g.nvim_tree_highlight_opened_files = 0 -- Will enable folder and file icon highlight for opened files/directories.
vim.g.nvim_tree_add_trailing = 0 -- Append a trailing slash to folder names. ]]

nvim_tree.setup({
  disable_netrw = true,
  hijack_netrw = true,
  open_on_setup = false,
  ignore_ft_on_setup = {
    "startify",
    "dashboard",
    "alpha",
  },
  auto_close = true,
  open_on_tab = false,
  hijack_cursor = false,
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
  update_focused_file = {
    enable = true,
    update_cwd = true,
    ignore_list = {},
  },
  system_open = {
    cmd = nil,
    args = {},
  },
  filters = {
    -- do not show dotfiles
    dotfiles = false,
    -- ignore these types in listing
    custom = { ".git", "node_modules", ".cache", "__pycache__" },
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = "20%",
    side = "right",
    mappings = {
      custom_only = false,
      list = {
        { key = "<S-h>", cb = ":call ResizeLeft(3)<CR>" },
        { key = "<C-h>", cb = tree_cb("toggle_dotfiles") },
        { key = { "l", "<CR>", "o" }, cb = tree_cb("edit") },
        { key = "h", cb = tree_cb("close_node") },
        { key = "v", cb = tree_cb("vsplit") },
      },
    },
    number = false,
    relativenumber = false,
    hide_root_folder = false,
    auto_resize = true,
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
  open_file = {
    quit_on_open = false,
    resize_window = false,
  },
  quit_on_open = 0,
  git_hl = 1,
  disable_window_picker = 0,
  root_folder_modifier = ":t",
  show_icons = {
    git = 1,
    folders = 1,
    files = 1,
    folder_arrows = 1,
    tree_width = 30,
  },
})

local map_opt = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeToggle<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>r", ":NvimTreeRefresh<CR>", map_opt)
-- vim.api.nvim_set_keymap("n", "<leader>q", ":NvimTreeFindFile<CR>", map_opt)
