return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "lua-language-server",
        "luacheck",
        "shfmt",
        "mypy",
        "pyright",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "typescript-language-server",
        "eslint-lsp",
        "phpactor",
        "phpcs",
        "php-cs-fixer",
        "hadolint",
        "markdownlint",
        "prettier",
        "prisma-language-server",
        "ruff",
        "taplo",
        "yq",
        "codelldb",
        "goimports",
        "actionlint",
      },
    },
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "BufReadPre",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      {
        "mrcjkb/rustaceanvim",
        version = "^4",
        ft = { "rust" },
        keys = {
          {
            "<leader>rr",
            "<cmd>RustLsp runnables<CR>",
            desc = "LSP: [R]ust [R]unnables",
          },
          {
            "<leader>rd",
            "<cmd>RustLsp debuggables<CR>",
            desc = "LSP: [R]ust [D]ebuggables",
          },
        },
      },
    },
    opts = function()
      local lspconfig = require("lspconfig")
      local icons = require("config.icons")
      for type, icon in pairs(icons.diagnostics) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
      return {
        ensure_installed = {
          "eslint",
          "ts_ls",
          "tailwindcss",
          "pyright",
          "lua_ls",
          "jsonls",
          "omnisharp",
          "ruff_lsp",
          "terraformls",
          "gopls",
          "rust_analyzer",
        },
        automatic_installation = true,
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
          ["rust_analyzer"] = function()
            -- setup handled by rustaceanvim
          end,
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { "vim", "jit" },
                  },
                  workspace = {
                    library = {
                      [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                      [vim.fn.stdpath("config") .. "/lua"] = true,
                    },
                  },
                },
              },
            })
          end,
          ["pyright"] = function()
            lspconfig.pyright.setup({
              capabilities = (function()
                local capabilities = vim.lsp.protocol.make_client_capabilities()
                capabilities.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }
                return capabilities
              end)(),
              settings = {
                python = {
                  analysis = {
                    typeCheckingMode = "off",
                  },
                },
              },
            })
          end,
        },
      }
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        vue = { "prettier" },
        svelte = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        docker = { "prettier" },
        sh = { "shfmt" },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        yaml = { "yq" },
        toml = { "taplo" },
        tf = { "terraform_fmt" },
        python = function(bufnr)
          if require("conform").get_formatter_info("ruff_format", bufnr).available then
            return { "ruff_fix", "ruff_format" }
          else
            return { "isort", "black" }
          end
        end,
        ["_"] = { "trim_whitespace", "trim_newlines" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        lua = { "luacheck" },
        docker = { "hadolint" },
      }
    end,
  },
}
