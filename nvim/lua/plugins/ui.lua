return {
  {
    "rcarriga/nvim-notify",
  },
  {
    "stevearc/dressing.nvim",
  },
  { 
    "MunifTanjim/nui.nvim", 
    lazy = true 
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    }
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true 
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("dashboard").setup({})
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup()
    end
  }
}
