local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  print("Fail to load Lazy")
  return
end

return lazy.setup(
  { { import = "knth.plugins" }, { import = "knth.plugins.lsp" } },
  {
    checker = {
      enabled = true,
      notify = false
    },
    change_detection = {
      enabled = false,
      notify = false
    },
  }
)
