return {
  -- Add git related info in the signs columns and popups
  "lewis6991/gitsigns.nvim",
  config = function()
    -- Gitsigns
    local status_ok, gitsigns = pcall(require, "gitsigns")
    if not status_ok then
      return
    end

    gitsigns.setup({
      -- signs = {
      --   add = { hl = "GitGutterAdd", text = "+" },
      --   change = { hl = "GitGutterChange", text = "~" },
      --   delete = { hl = "GitGutterDelete", text = "_" },
      --   topdelete = { hl = "GitGutterDelete", text = "‾" },
      --   changedelete = { hl = "GitGutterChange", text = "~" },
      -- },
      -- signs = {
      --   add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
      --   change = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
      --   delete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
      --   topdelete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
      --   changedelete = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
      -- },
    })
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
}
