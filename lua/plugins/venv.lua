return {
  "linux-cultist/venv-selector.nvim",
  dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
  opts = function()
    local poetry_path = "~/.cache/pypoetry/virtualenvs"
    if vim.loop.os_uname().sysname == "Darwin" then
      poetry_path = "~/Library/Caches/pypoetry/virtualenvs"
    end
    return {
      name = { "venv", ".venv" },
      auto_refresh = true,
      search_workspace = true,
      poetry_path = poetry_path,
    }
  end,
  keys = {
    { "<leader>vs", "<cmd>VenvSelect<cr>" },
    { "<leader>vc", "<cmd>VenvSelectCached<cr>" },
  },
}
