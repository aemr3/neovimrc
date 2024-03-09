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
      opts["desc"] = "LSP: " .. opts["desc"]
      vim.keymap.set(mode, lhs, rhs, opts)
    end
    local telescope_builtin = require("telescope.builtin")
    map("n", "gd", telescope_builtin.lsp_definitions, { desc = "[G]oto [D]efinition" })
    map("n", "gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })
    map("n", "gr", telescope_builtin.lsp_references, { desc = "[G]oto [R]eferences" })
    map("n", "gI", telescope_builtin.lsp_implementations, { desc = "[G]oto [I]mplementation" })
    map("n", "<leader>D", telescope_builtin.lsp_type_definitions, { desc = "Type [D]efinition" })
    map("n", "<leader>ds", telescope_builtin.lsp_document_symbols, { desc = "[D]ocument [S]ymbols" })
    map("n", "<leader>ws", telescope_builtin.lsp_dynamic_workspace_symbols, { desc = "[W]orkspace [S]ymbols" })
    map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame Symbol" })
    map("n", "K", vim.lsp.buf.hover, { desc = "Show Documentation" })
    map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
    map("n", "<leader>cf", "<cmd>lua vim.lsp.buf.format({ name = 'efm' })<cr>", { desc = "[C]ode [F]ormat" })

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = ev.buf,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = ev.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
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
