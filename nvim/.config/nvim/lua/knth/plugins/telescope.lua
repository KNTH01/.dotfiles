-- Telescope

local present, telescope = pcall(require, "telescope")
if not present then
  return
end

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    },
    prompt_prefix = "🔎︎ ",
    selection_caret = "➤ ",
    entry_prefix = "  ",
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    use_less = true,
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
  },
})

-- mappings

-- Function for make mapping easier.
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.api.nvim_set_keymap('n', '<leader>sf', [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]], { noremap = true, silent = true })
-- map("n", "<Leader>ff", ":Telescope find_files<CR>")
map("n", "<Leader>ff", [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]])
map("n", "<Leader>fg", ":Telescope live_grep<CR>")
map("n", "<Leader>fw", ":Telescope grep_string<CR>")
map("n", "<Leader>fp", ":Telescope media_files<CR>")
-- map("n", "<Leader>fb", ":Telescope buffers<CR>")
map("n", "<Leader>fb", [[<cmd>lua require('telescope.builtin').buffers({previewer = false})<CR>]])
map("n", "<Leader>fh", ":Telescope help_tags<CR>")
map("n", "<Leader>fo", ":Telescope oldfiles<CR>")
map("n", "<Leader>th", ":Telescope colorscheme<CR>")
map("n", "<Leader>gs", ":Telescope git_status<CR>")
map("n", "<Leader>cm", ":Telescope git_commits<CR>")
map("n", "<Leader><space>", ":Telescope current_buffer_fuzzy_find<CR>")
-- map("n", "<Leader>ft", ":Telescope tags<CR>")
-- map("n", "<Leader>ft", [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]])
