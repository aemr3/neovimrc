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
        "intelephense",
        "phpcs",
        "php-cs-fixer",
        "hadolint",
        "markdownlint",
        "prettierd",
        "fixjson",
        "prisma-language-server",
        "ruff",
        "taplo",
        "yq",
        "codelldb",
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
      "creativenull/efmls-configs-nvim",
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
          "efm",
          "eslint",
          "tsserver",
          "tailwindcss",
          "pyright",
          "lua_ls",
          "jsonls",
          "omnisharp",
          "ruff_lsp",
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
          ["efm"] = function()
            local luacheck = require("efmls-configs.linters.luacheck")
            local stylua = require("efmls-configs.formatters.stylua")
            local eslint = require("efmls-configs.linters.eslint")
            local prettier_d = require("efmls-configs.formatters.prettier_d")
            local fixjson = require("efmls-configs.formatters.fixjson")
            local shfmt = require("efmls-configs.formatters.shfmt")
            local hadolint = require("efmls-configs.linters.hadolint")
            local ruff = require("efmls-configs.formatters.ruff")
            local gofmt = require("efmls-configs.formatters.gofmt")
            local taplo = require("efmls-configs.formatters.taplo")
            local yq = require("efmls-configs.formatters.yq")
            local dotnet_format = require("efmls-configs.formatters.dotnet_format")
            local rustfmt = require("efmls-configs.formatters.rustfmt")

            lspconfig.efm.setup({
              filetypes = {
                "lua",
                "python",
                "json",
                "jsonc",
                "sh",
                "javascript",
                "javascriptreact",
                "typescript",
                "typescriptreact",
                "svelte",
                "vue",
                "markdown",
                "docker",
                "html",
                "css",
                "go",
                "cs",
                "rust",
                "yaml",
                "toml",
              },
              init_options = {
                documentFormatting = true,
                documentRangeFormatting = true,
                hover = true,
                documentSymbol = true,
                codeAction = true,
                completion = true,
              },
              settings = {
                languages = {
                  lua = { luacheck, stylua },
                  python = { ruff },
                  typescript = { prettier_d },
                  json = { eslint, fixjson },
                  jsonc = { eslint, fixjson },
                  sh = { shfmt },
                  javascript = { prettier_d },
                  javascriptreact = { prettier_d },
                  typescriptreact = { prettier_d },
                  svelte = { eslint, prettier_d },
                  vue = { prettier_d },
                  markdown = { prettier_d },
                  docker = { hadolint, prettier_d },
                  html = { prettier_d },
                  css = { prettier_d },
                  go = { gofmt },
                  cs = { dotnet_format },
                  rust = { rustfmt },
                  yaml = { yq },
                  toml = { taplo },
                },
              },
            })
          end,
        },
      }
    end,
  },
}
