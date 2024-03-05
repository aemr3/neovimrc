return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      sources = {
        "filesystem",
        -- "buffers",
        -- "git_status",
        -- "document_symbols",
      },
      default_source = "filesystem",
      source_selector = {
        winbar = true,
        statusline = false,
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
          { source = "git_status" },
          { source = "document_symbols" },
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          never_show = {
            "__pycache__",
            ".DS_Store",
            ".git",
          },
        },
      },
    },
    keys = {
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer explorer",
      },
      { "<leader>fe", "<cmd>Neotree toggle<cr>", desc = "Browse Files" },
      { "<leader>e", "<leader>fe", desc = "Browse Files", remap = true },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },
}
