return {
  "linux-cultist/venv-selector.nvim",
  opts = {
    name = { "venv", ".venv" },
    auto_refresh = true,
    search_workspace = false,
    poetry_path = "~/Library/Caches/pypoetry/virtualenvs",
  },
  dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
  keys = {
    { "<leader>vs", "<cmd>VenvSelect<cr>" },
    { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
  },
}
