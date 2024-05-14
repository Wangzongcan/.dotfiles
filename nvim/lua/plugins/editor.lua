return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      {
        "nvim-telescope/telescope-project.nvim",
        enabled = true,
        config = function()
          require("telescope").load_extension("project")
        end
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = true,
        config = function()
          require("telescope").load_extension("fzf")
        end
      },
    },
    opts = {
      defaults = {
        sorting_strategy = 'ascending',
        layout_config = {
          horizontal = {
            prompt_position = "top",
          },
        },
      } 
    },
    keys = {
      { "<leader>pp", "<cmd>Telescope project<cr>" },
      { 
        "<leader>pf", 
        function() 
          local result = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null")
          if result ~= "" and vim.v.shell_error == 0 then
            require("telescope.builtin").git_files()
          else
            require("telescope.builtin").find_files()
          end
        end
      }
    }
  },
  {
    "echasnovski/mini.diff",
    config = function()
      require("mini.diff").setup({
        view = {
          style = "sign",
          signs = {
            add = "▎",
            change = "▎",
            delete = "",
          },
        },
      })
    end
  }
}
