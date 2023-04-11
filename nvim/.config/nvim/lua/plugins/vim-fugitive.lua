return
{
  -- Git commands in nvim
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set("n", "<leader>gs", [[:tab G<cr>]])
  end
}
