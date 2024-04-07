return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",

    config = function()
      -- Treesitter configuration
      -- Parsers must be installed manually via :TSInstall

      local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
      if not status_ok then
        return
      end

      treesitter_configs.setup({
        highlight = {
          enable = true, -- `false` will disable the whole extension
        },
        -- enable indentation
        indent = { enable = true, disable = { "yaml" } },
        -- enable autotagging (w/ nvim-ts-autotag plugin)
        autotag = { enable = true },
        -- ensure these language parsers are installed
        ensure_installed = {
          "rust",
          "javascript",
          "typescript",
          "html",
          "css",
          "lua",
          "json",
          "tsx",
          "yaml",
          "markdown",
          "svelte",
          "graphql",
          "bash",
          "vim",
          "dockerfile",
          "gitignore",
          "markdown_inline",
          "regex"
        },
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- autoclose tags
      "windwp/nvim-ts-autotag",
      -- A super powerful autopairs for Neovim. It support multiple character
      {
        "windwp/nvim-autopairs",
        config = function()
          local setup_ok, autopairs = pcall(require, "nvim-autopairs")
          if not setup_ok then
            return
          end

          autopairs.setup({
            check_ts = true,
            enable_check_bracket_line = true,                -- Don't add pairs if it already have a close pairs in same line
            disable_filetype = { "TelescopePrompt", "vim" }, --
            enable_afterquote = false,                       -- add bracket pairs after quote
            enable_moveright = true,
          })

          -- If you want insert `(` after select function or method item
          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          local cmp = require("cmp")
          cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
          local Rule = require("nvim-autopairs.rule")
          local npairs = require("nvim-autopairs")

          npairs.add_rules({

            -- before   insert  after
            --  (|)     ( |)	( | )
            Rule(" ", " "):with_pair(function(opts)
              local pair = opts.line:sub(opts.col - 1, opts.col)
              return vim.tbl_contains({ "()", "[]", "{}" }, pair)
            end),
            Rule("( ", " )")
                :with_pair(function()
                  return false
                end)
                :with_move(function(opts)
                  return opts.prev_char:match(".%)") ~= nil
                end)
                :use_key(")"),
            Rule("{ ", " }")
                :with_pair(function()
                  return false
                end)
                :with_move(function(opts)
                  return opts.prev_char:match(".%}") ~= nil
                end)
                :use_key("}"),
            Rule("[ ", " ]")
                :with_pair(function()
                  return false
                end)
                :with_move(function(opts)
                  return opts.prev_char:match(".%]") ~= nil
                end)
                :use_key("]"),
            --[===[
  arrow key on javascript
      Before 	Insert    After
      (item)= 	> 	    (item)=> { }
  --]===]
            Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript" })
                :use_regex(true)
                :set_end_pair_length(2),
          })
        end
      },

    }
  },
  "nvim-treesitter/playground",
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require 'treesitter-context'.setup {
        enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
        trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
      }
    end
  }
}
