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

-- for Obsidian
vim.opt.conceallevel = 2

-- relative line numbers
vim.opt.relativenumber = true

-- Shortcuts:

autocmd("FileType", {
	pattern = "markdown",
	command = "setlocal spell",
})
