--
-- vim.fn            -- call Vim functions
-- vim.g             -- global variables
-- vim.bo            -- buffer-scoped options
-- vim.wo            -- windows-scoped options
--

-- set gruvbox theme
vim.cmd([[colorscheme gruvbox]])

vim.opt.guifont = "DroidSansMono Nerd Font 12"

-- Enable GUI colors for the terminal to get truecolor
-- set colorscheme (order is important here)
vim.opt.termguicolors = true
vim.g.gruvbox_terminal_italics = 2

-- Set statusbar
vim.g.lightline = {
  colorscheme = "gruvbox",
  active = { left = { { "mode", "paste" }, { "gitbranch", "readonly", "filename", "modified" } } },
  component_function = { gitbranch = "fugitive#head" },
}

-- show whitespace
vim.opt.list = false

vim.opt.listchars = {
  nbsp = "⦸", -- CIRCLED REVERSE SOLIDUS (U+29B8, UTF-8: E2 A6 B8)
  extends = "»", -- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB, UTF-8: C2 BB)
  precedes = "«", -- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB, UTF-8: C2 AB)
  tab = "▷─", -- WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7) + BOX DRAWINGS HEAVY TRIPLE DASH HORIZONTAL (U+2505, UTF-8: E2 94 85)
  trail = "•", -- BULLET (U+2022, UTF-8: E2 80 A2)
  space = "-",
}

vim.opt.fillchars = {
  diff = "∙", -- BULLET OPERATOR (U+2219, UTF-8: E2 88 99)
  eob = " ", -- NO-BREAK SPACE (U+00A0, UTF-8: C2 A0) to suppress ~ at EndOfBuffer
  fold = "·", -- MIDDLE DOT (U+00B7, UTF-8: C2 B7)
  vert = " ", -- remove ugly vertical lines on window division
}

-- show the matching part of the pair for [] {} and ()
vim.opt.showmatch = true

-- make backspace behave like normal again
vim.opt.backspace = "indent,start,eol"

-- tabs
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2 -- spaces per tab (when shifting), when using the >> or << commands, shift lines by 4 spaces
vim.opt.tabstop = 2 -- spaces per tab
vim.opt.smarttab = true -- <tab>/<BS> indent/dedent in leading whitespace
vim.opt.autoindent = true -- maintain indent of current line
vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.shiftround = true

-- open horizontal splits below current window
vim.opt.splitbelow = true
-- open vertical splits to the right of the current window
vim.opt.splitright = true

-- always show status line
vim.opt.laststatus = 2

-- shell to use for `!`, `:!`, `system()` etc.
vim.opt.shell = "zsh"

-- incremental live completion, e.g: the :s command
vim.opt.inccommand = "nosplit"

--Set highlight on search
vim.opt.hlsearch = true

-- incremental search
vim.opt.incsearch = true

--Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- line wrap
vim.opt.wrap = true

-- highlight current line
vim.opt.cursorline = false

-- allows user to hide buffers with unsaved changes without being prompted
vim.opt.hidden = true

--Enable mouse mode
vim.opt.mouse = "a"

--Enable break indent
vim.opt.breakindent = true

--Save undo history
vim.opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

--Decrease update time - CursorHold interval
vim.opt.updatetime = 250

vim.wo.signcolumn = "yes"

-- Add a nice vertical scroll offset
vim.opt.scrolloff = 8
-- Add a side scroll offset, this is used when wrap is off
vim.opt.sidescrolloff = 8

-- creates a backup file
vim.opt.backup = false

-- allows neovim to access the system clipboard
vim.opt.clipboard = "unnamedplus"

-- set height for the command input below
vim.opt.cmdheight = 1

-- case insensitive in `command-line` mode
vim.opt.wildignorecase = true

------------------------------------------------
------------------------------------------------

-- highlight on yank
vim.api.nvim_exec(
  [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=500, on_visual=true}
  augroup end
]],
  false
)

-- jump to the last position when reopening a file
vim.cmd([[
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
]])

-- patterns to ignore during file-navigation
vim.opt.wildignore = vim.opt.wildignore + "*.o,*.rej,*.so"

-- remove whitespace on save
vim.cmd([[au BufWritePre * :%s/\s\+$//e]])

-- faster scrolling
vim.opt.lazyredraw = true

-- don't auto commenting new lines -- doesn't work????
vim.cmd([[au BufEnter * set fo-=c fo-=r fo-=o]])
-- op newline continution of comments
vim.api.nvim_exec([[setlocal formatoptions-=cro]], false)

-- 2 spaces for selected filetypes
-- vim.cmd([[ autocmd FileType xml,html,xhtml,css,scssjavascript,lua,dart setlocal shiftwidth=2 tabstop=2 ]])
-- 4 spaces for selected filetypes
-- vim.cmd([[ autocmd FileType python,c,cpp setlocal shiftwidth=4 tabstop=4 ]])
-- 8 spaces for Go files
-- vim.cmd([[ autocmd FileType go setlocal shiftwidth=8 tabstop=8 ]])

--[[
    NOTE: et = extand tab
          ai = autoindent
          fo = Create a fold for the lines in {range}.
]]

-- lua
vim.cmd([[ au BufEnter *.lua set ai expandtab shiftwidth=2 tabstop=2 sta fo=croql ]])
-- vim
vim.cmd([[ au BufEnter *.vim set ai expandtab shiftwidth=2 tabstop=2 sta fo=croql ]])
-- json
vim.cmd([[ au BufEnter *.json set ai expandtab shiftwidth=2 tabstop=2 sta fo=croql ]])
