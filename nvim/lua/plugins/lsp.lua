return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
    {
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup()
      end
    },
    {
      "williamboman/mason-lspconfig.nvim",
      cmd = { "LspInstall", "LspUninstall" },
      config = function()
        require("mason-lspconfig").setup()
      end
    }
  },
  config = function()
    require'lspconfig'.volar.setup({})
  end
}
