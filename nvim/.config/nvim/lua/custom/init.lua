local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
--
-- d and c should not delete the register
autocmd("TextYankPost", {
  pattern = "*",
  command = "silent! lua vim.highlight.on_yank()",
})

autocmd("BufReadPost", {
  pattern = "/srv/http/wordpress/*",
  callback = function()
    if vim.fn.filewritable(vim.fn.expand "%") == 2 then
      vim.bo.readonly = false
    end
  end,
})

-- for Obsidian
vim.opt.conceallevel = 2
