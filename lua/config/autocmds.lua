local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- lsp on attach
autocmd("LspAttach", {
  group = augroup("UserLspConfig", {}),
  callback = function(ev)
    local bufnr = ev.buf
    local map = function(mode, lhs, rhs, opts)
      local _opts = { noremap = true, silent = true, buffer = bufnr }
      for k, v in pairs(_opts) do
        opts[k] = v
      end
      vim.keymap.set(mode, lhs, rhs, opts)
    end
    map("n", "gD", vim.lsp.buf.declaration, { desc = "[LSP] Goto Declaration" })
    map("n", "gd", vim.lsp.buf.definition, { desc = "[LSP] Goto Definition" })
    map("n", "K", vim.lsp.buf.hover, { desc = "[LSP] Show Documentation" })
    map("n", "gi", vim.lsp.buf.implementation, { desc = "[LSP] Goto Implementation" })
    map("n", "gK", vim.lsp.buf.signature_help, { desc = "[LSP] Signature Help" })
    map("n", "<leader>D", vim.lsp.buf.type_definition, { desc = "[LSP] Type Definition" })
    map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[LSP] Rename Symbol" })
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[LSP] Code Actions" })
    map("n", "gr", vim.lsp.buf.references, { desc = "[LSP] Show References" })
    map("n", "<leader>cf", "<cmd>lua vim.lsp.buf.format({ name = 'efm' })<cr>", { desc = "[LSP] Format" })
  end,
})

-- auto format on save
autocmd("BufWritePost", {
  group = augroup("LspFormattingGroup", {}),
  callback = function(ev)
    local efm = vim.lsp.get_active_clients({ name = "efm", bufnr = ev.buf })
    local ruff = vim.lsp.get_active_clients({ name = "ruff_lsp", bufnr = ev.buf })

    if vim.tbl_isempty(efm) or vim.g.format_on_save == nil or not vim.g.format_on_save then
      return
    end

    if not vim.tbl_isempty(ruff) then
      vim.lsp.buf.code_action({
        context = {
          only = { "source.organizeImports.ruff" },
        },
        apply = true,
      })
      vim.wait(100)
      vim.cmd(":w")
    end

    vim.lsp.buf.format({ name = "efm" })
    vim.wait(100)
  end,
})

-- highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYankGroup", {}),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- select cached venv
autocmd("DirChanged", {
  callback = function()
    local venv = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
    if venv ~= "" then
      require("venv-selector").retrieve_from_cache()
    end
  end,
})

-- format prisma files
autocmd("BufWritePost", {
  pattern = "*.prisma",
  command = "!npx prisma format",
})
