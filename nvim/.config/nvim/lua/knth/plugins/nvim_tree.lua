local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

nvim_tree.setup({
  renderer = {
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      },
      glyphs = {
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
      },
    },
  },
  disable_netrw = true,
  hijack_netrw = true,
  view = {
    width = "20%",
    side = "right",
  },
  actions = {
    open_file = {
      quit_on_open = true,
      resize_window = true,
    },
  },
})

local map_opt = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeToggle<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>r", ":NvimTreeRefresh<CR>", map_opt)
vim.api.nvim_set_keymap("n", "<leader>p", ":NvimTreeFindFile<CR>", map_opt)
