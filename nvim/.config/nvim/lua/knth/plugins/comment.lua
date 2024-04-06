return {
  -- commenting plugin
  "numToStr/Comment.nvim",
  config = function()
    -- load default config
    require('Comment').setup()
  end
}
