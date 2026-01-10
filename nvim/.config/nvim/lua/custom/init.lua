local autocmd = vim.api.nvim_create_autocmd

-- d and c should not delete the register
autocmd("TextYankPost", {
	pattern = "*",
	command = "silent! lua vim.highlight.on_yank()",
})

vim.opt.number = true -- Show current line number
vim.opt.relativenumber = true -- Show relative line numbers

-- Shortcuts:

autocmd("FileType", {
	pattern = "markdown",
	command = "setlocal spell",
})

-- Set filetype detection for .vtt files
vim.filetype.add({
	extension = {
		vtt = "vtt",
	},
})

-- Set up an autocommand to call set_vtt_mappings when opening a .vtt file
vim.api.nvim_create_autocmd("FileType", {
	pattern = "vtt",
	callback = function()
		require("core.utils").load_mappings("vtt")
	end,
})

-- Set up statuscolumn
vim.opt.statuscolumn = "%s %l %r"
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "󰌵",
		},
	},
})
