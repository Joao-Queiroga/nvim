local bufnr = vim.api.nvim_get_current_buf()
local keymap = vim.keymap.set
keymap("n", "<leader>la", function()
  vim.cmd.RustLsp("codeAction")
end, { silent = true, buffer = bufnr })

keymap("n", "K", function()
  vim.cmd.RustLsp({ "hover", "actions" })
end, { silent = true, buffer = bufnr })
