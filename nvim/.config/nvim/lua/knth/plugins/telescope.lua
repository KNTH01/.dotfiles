-- Telescope

local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
  return
end

local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
  return
end

telescope.setup({
  defaults = {
    -- prompt_prefix = " ",
    -- selection_caret = " ",
    prompt_prefix = "🔎︎ ",
    selection_caret = "➤ ",

    path_display = { "smart" },

    pickers = {
      -- Default configuration for builtin pickers goes here:
      -- picker_name = {
      --   picker_config_key = value,
      --   ...
      -- }
      -- Now the picker_config_key will be applied every time you call this
      -- builtin picker
    },

    extensions = {
      media_files = {
        -- filetypes whitelist
        -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        filetypes = { "png", "webp", "jpg", "jpeg" },
        find_cmd = "rg", -- find command (defaults to `fd`)
      },
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
      -- Your extension configuration goes here:
      -- extension_name = {
      --   extension_config_key = value,
      -- }
      -- please take a look at the readme of the extension you want to configure
    },

    mappings = {
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-c>"] = actions.close,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
        -- ["<C-u>"] = false,
        -- ["<C-d>"] = false,

        ["<PageUp>"] = actions.results_scrolling_up,
        ["<PageDown>"] = actions.results_scrolling_down,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<C-l>"] = actions.complete_tag,
        ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
      },

      n = {
        ["<esc>"] = actions.close,
        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
        ["H"] = actions.move_to_top,
        ["M"] = actions.move_to_middle,
        ["L"] = actions.move_to_bottom,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,
        ["gg"] = actions.move_to_top,
        ["G"] = actions.move_to_bottom,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,

        ["<PageUp>"] = actions.results_scrolling_up,
        ["<PageDown>"] = actions.results_scrolling_down,

        ["?"] = actions.which_key,
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

    -- entry_prefix = "  ",
    -- winblend = 0,
    -- border = {},
    -- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    -- color_devicons = true,
    -- use_less = true,
    -- set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
  },
})

-- Load Telescope extensions
telescope.load_extension("fzf")
telescope.load_extension("media_files")

-- mappings

vim.keymap.set("n", "<Leader>ff", [[<cmd>lua require('telescope.builtin').find_files({previewer = false})<CR>]])
vim.keymap.set("n", "<Leader>fg", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<Leader>fw", ":Telescope grep_string<CR>")
vim.keymap.set("n", "<Leader>fp", ":Telescope media_files<CR>")
-- vim.keymap.set("n", "<Leader>fb", ":Telescope buffers<CR>")
vim.keymap.set("n", "<Leader>fb", [[<cmd>lua require('telescope.builtin').buffers({previewer = false})<CR>]])
vim.keymap.set("n", "<Leader>fh", ":Telescope help_tags<CR>")
vim.keymap.set("n", "<Leader>fo", ":Telescope oldfiles<CR>")
vim.keymap.set("n", "<Leader>th", ":Telescope colorscheme<CR>")
vim.keymap.set("n", "<Leader>gs", ":Telescope git_status<CR>")
vim.keymap.set("n", "<Leader>cm", ":Telescope git_commits<CR>")
vim.keymap.set("n", "<Leader><space>", ":Telescope current_buffer_fuzzy_find<CR>")
-- vim.keymap.set("n", "<Leader>ft", ":Telescope tags<CR>")
-- vim.keymap.set("n", "<Leader>ft", [[<cmd>lua require('telescope.builtin').tags{ only_current_buffer = true }<CR>]])
