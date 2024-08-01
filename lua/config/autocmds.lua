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
    map("n", "<leader>cf", function()
      require("conform").format({ lsp_fallback = true })
    end, { desc = "[C]ode [F]ormat" })

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

-- highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYankGroup", {}),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- format prisma files
autocmd("BufWritePost", {
  pattern = "*.prisma",
  command = "!npx prisma format",
})
