--
-- vim.fn            -- call Vim functions
-- vim.g             -- global variables
-- vim.bo            -- buffer-scoped options
-- vim.wo            -- windows-scoped options
--

local options = {
  -- set term gui colors (most terminals support this)
  termguicolors = true,

  -- allows neovim to access the system clipboard
  clipboard = "unnamedplus",

  -- set height for the command input below
  cmdheight = 1,

  -- mostly just for cmp
  completeopt = { "menuone", "noselect" },

  -- so that `` is visible in markdown files
  conceallevel = 0,

  -- the encoding written to a file
  fileencoding = "utf-8",

  -- incremental search
  incsearch = true,

  -- highlight all matches on previous search pattern
  hlsearch = true,

  -- ignore case in search patterns
  ignorecase = true,

  -- smart case
  smartcase = true,

  -- allow the mouse to be used in neovim
  mouse = "a",

  -- pop up menu height
  pumheight = 10,

  -- we don't need to see things like -- INSERT -- anymore
  showmode = false,

  -- always show tabs
  showtabline = 2,

  -- make indenting smarter again
  smartindent = true,

  -- force all horizontal splits to go below current window
  splitbelow = true,

  -- force all vertical splits to go to the right of current window
  splitright = true,

  -- creates a swapfile
  swapfile = false,

  -- creates a backup file
  backup = false,

  -- time to wait for a mapped sequence to complete (in milliseconds)
  timeoutlen = 1000,

  -- enable persistent undo
  undofile = true,

  -- faster completion (4000ms default)
  updatetime = 250,

  -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  writebackup = false,

  -- convert tabs to spaces
  expandtab = true,

  -- the number of spaces inserted for each indentation
  shiftwidth = 2,

  -- insert 2 spaces for a tab
  tabstop = 2,

  -- highlight the current line
  cursorline = true,

  -- set numbered lines
  number = true,

  -- set relative numbered lines
  relativenumber = true,

  -- set number column width to 2 {default 4}
  numberwidth = 4,

  -- always show the sign column, otherwise it would shift the text each time
  signcolumn = "yes",

  -- wrap line
  wrap = true,

  -- add a nice vertical scroll offset
  scrolloff = 8,

  -- add a side scroll offset, this is used when wrap is off
  sidescrolloff = 8,

  -- show whitespace
  list = false,

  listchars = {
    nbsp = "⦸", -- CIRCLED REVERSE SOLIDUS (U+29B8, UTF-8: E2 A6 B8)
    extends = "»", -- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB, UTF-8: C2 BB)
    precedes = "«", -- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB, UTF-8: C2 AB)
    tab = "▷─", -- WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7) + BOX DRAWINGS HEAVY TRIPLE DASH HORIZONTAL (U+2505, UTF-8: E2 94 85)
    trail = "•", -- BULLET (U+2022, UTF-8: E2 80 A2)
    space = "-",
  },

  fillchars = {
    diff = "∙", -- BULLET OPERATOR (U+2219, UTF-8: E2 88 99)
    eob = " ", -- NO-BREAK SPACE (U+00A0, UTF-8: C2 A0) to suppress ~ at EndOfBuffer
    fold = "·", -- MIDDLE DOT (U+00B7, UTF-8: C2 B7)
    vert = " ", -- remove ugly vertical lines on window division
  },

  -- case insensitive in `command-line` mode
  wildignorecase = true,

  -- show the matching part of the pair for [] {} and ()
  showmatch = true,

  -- make backspace behave like normal again
  backspace = "indent,start,eol",

  -- tabs
  softtabstop = 2,

  -- <tab>/<BS> indent/dedent in leading whitespace
  smarttab = true,

  -- maintain indent of current line
  autoindent = true,

  -- shiftround?
  shiftround = true,

  -- always show status line
  laststatus = 2,

  -- shell to use for `!`, `:!`, `system()` etc.
  shell = "zsh",

  -- incremental live completion, e.g: the :s command
  inccommand = "nosplit",

  -- allows user to hide buffers with unsaved changes without being prompted
  hidden = true,

  --Enable break indent
  breakindent = true,
}

-- apply options listed above
for k, v in pairs(options) do
  vim.opt[k] = v
end

--
-- Theming
--

-- font
vim.opt.guifont = "DroidSansMono Nerd Font 12"

-- gruvbox-flat config
vim.g.gruvbox_flat_style = "dark"
-- make comment italics
vim.g.gruvbox_italic_functions = true
-- make functions italic
vim.g.gruvbox_italic_comments = true
-- make keyword italic
vim.g.gruvbox_italic_keywords = true
-- set a darker background_color for sidebar, e.g: NvimTree
vim.g.gruvbox_dark_sidebar = true
-- set a darker background_color for float windows, e.g: Notify
vim.g.gruvbox_dark_float = true
-- set the background to be not transparent
vim.g.gruvbox_transparent = false

-- set gruvbox theme
-- must be set AFTER the theme's config
vim.cmd([[colorscheme gruvbox-flat]])

-- set onedarkpro light theme
local onedarkpro = require("onedarkpro")
onedarkpro.load()

--
-- Commands
--

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

-- don't auto commenting new lines
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

-- set kebabcase as word
vim.cmd([[set iskeyword+=-]])
