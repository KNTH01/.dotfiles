return {
  "RRethy/vim-illuminate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("illuminate").configure({
      delay = 200
    })

    vim.api.nvim_command('highlight IlluminatedWordText guibg=#414559 gui=NONE')
    vim.api.nvim_command('highlight IlluminatedWordRead guibg=#414559 gui=NONE')
    vim.api.nvim_command('highlight IlluminatedWordWrite guibg=#414559 gui=NONE')
    -- local frappe = require("catppuccin.palettes").get_palette "frappe"
    -- vim.api.nvim_command(string.format('highlight IlluminatedWordText guibg=%s gui=NONE', frappe.surface0))
    -- vim.api.nvim_command(string.format('highlight IlluminatedWordText guibg=%s gui=NONE', frappe.surface0))
    -- vim.api.nvim_command(string.format('highlight IlluminatedWordText guibg=%s gui=NONE', frappe.surface0))
    --
    -- latte
    -- vim.api.nvim_command('highlight IlluminatedWordText guibg=#ccd0da gui=NONE')
    -- vim.api.nvim_command('highlight IlluminatedWordRead guibg=#ccd0da gui=NONE')
    -- vim.api.nvim_command('highlight IlluminatedWordWrite guibg=#ccd0da gui=NONE')
  end
}
