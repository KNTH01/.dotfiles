return {
  -- AutoSave
  "Pocco81/AutoSave.nvim",
  config = function()
    vim.api.nvim_set_keymap("n", "<leader>A", ":ASToggle<CR>", {})
  end
}
