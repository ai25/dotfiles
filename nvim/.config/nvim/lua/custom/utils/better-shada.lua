-- -- Create an autocommand group for oldfiles management
-- local oldfiles_group = vim.api.nvim_create_augroup("OldfilesPersistent", { clear = true })
--
-- -- Ensure shada is configured to store enough oldfiles
-- -- Add this to your init.lua if not already present
-- vim.opt.shada = "'10000,<100,s50,h,f1"
-- -- '100 = remember marks for last 100 files
-- -- <50 = save up to 50 lines for each register
-- -- s10 = skip items larger than 10KB
-- -- h = disable hlsearch highlighting when starting
-- -- f1 = store file marks
--
-- -- Function to add current file to oldfiles
-- local function add_to_oldfiles()
-- 	local current_file = vim.fn.expand("%:p")
--
-- 	if current_file == "" or vim.fn.filereadable(current_file) ~= 1 or vim.bo.buftype ~= "" then
-- 		return
-- 	end
--
-- 	-- First, ensure we have the latest shada data
-- 	vim.cmd("rshada!")
--
-- 	-- Now work with the complete oldfiles list
-- 	local oldfiles = vim.v.oldfiles or {}
--
-- 	-- Rest of your logic...
-- 	local found = false
-- 	for i, file in ipairs(oldfiles) do
-- 		if file == current_file then
-- 			table.remove(oldfiles, i)
-- 			table.insert(oldfiles, 1, current_file)
-- 			found = true
-- 			break
-- 		end
-- 	end
--
-- 	if not found then
-- 		table.insert(oldfiles, 1, current_file)
-- 	end
--
-- 	-- Limit size
-- 	local max_oldfiles = 10000
-- 	while #oldfiles > max_oldfiles do
-- 		table.remove(oldfiles)
-- 	end
--
-- 	vim.v.oldfiles = oldfiles
-- end
--
-- -- Update oldfiles when reading a file
-- vim.api.nvim_create_autocmd("BufReadPost", {
-- 	group = oldfiles_group,
-- 	callback = add_to_oldfiles,
-- 	desc = "Add file to oldfiles when opened",
-- })
--
-- -- Write shada periodically and on exit
-- vim.api.nvim_create_autocmd("FocusLost", {
-- 	group = oldfiles_group,
-- 	callback = function()
-- 		-- Read first, then write to merge
-- 		vim.cmd("rshada!")
-- 		vim.cmd("wshada!")
-- 	end,
-- 	desc = "Write shada when Neovim loses focus",
-- })
--
-- vim.api.nvim_create_autocmd("VimLeavePre", {
-- 	group = oldfiles_group,
-- 	callback = function()
-- 		-- Read existing shada data first
-- 		vim.cmd("rshada!")
-- 		vim.cmd("wshada!")
-- 	end,
-- 	desc = "Write shada before exiting Neovim",
-- })

-- -- Read shada on startup (this happens automatically, but we can ensure it)
-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	group = oldfiles_group,
-- 	once = true,
-- 	callback = function()
-- 		-- Delay slightly to ensure shada is loaded
-- 		vim.defer_fn(function()
-- 			vim.cmd("silent! rshada!")
-- 		end, 10)
-- 	end,
-- 	desc = "Ensure shada is read on startup",
-- })

-- Just configure shada properly and let Neovim handle oldfiles
-- vim.opt.shada = "'10000,<100,s50,h,f1"
--
-- -- Force periodic saves without manual oldfiles management
-- local oldfiles_group = vim.api.nvim_create_augroup("OldfilesPersistent", { clear = true })
--
-- vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
-- 	group = oldfiles_group,
-- 	callback = function()
-- 		-- Just ensure shada gets updated when we open files
-- 		vim.schedule(function()
-- 			vim.cmd("wshada!")
-- 		end)
-- 	end,
-- })
--
-- vim.api.nvim_create_autocmd("VimLeavePre", {
-- 	group = oldfiles_group,
-- 	callback = function()
-- 		vim.cmd("wshada!")
-- 	end,
-- })

-- Only modify v:oldfiles when we actually open a file
local function carefully_add_to_oldfiles()
	local current_file = vim.fn.expand("%:p")

	if current_file == "" or vim.fn.filereadable(current_file) ~= 1 or vim.bo.buftype ~= "" then
		return
	end

	-- Read current shada to get the complete oldfiles list
	vim.cmd("rshada!")

	-- Get the current oldfiles (which now includes shada data)
	local oldfiles = vim.list_slice(vim.v.oldfiles or {})

	-- Only modify if this file isn't already at the top
	if #oldfiles == 0 or oldfiles[1] ~= current_file then
		-- Remove file if it exists elsewhere
		for i = #oldfiles, 1, -1 do
			if oldfiles[i] == current_file then
				table.remove(oldfiles, i)
				break
			end
		end

		-- Add to front
		table.insert(oldfiles, 1, current_file)

		-- Trim if necessary
		while #oldfiles > 10000 do
			table.remove(oldfiles)
		end

		-- Update v:oldfiles
		vim.v.oldfiles = oldfiles
	end
end

-- local function safely_add_to_oldfiles()
-- 	local current_file = vim.fn.expand("%:p")
--
-- 	if current_file == "" or vim.fn.filereadable(current_file) ~= 1 or vim.bo.buftype ~= "" then
-- 		return
-- 	end
--
-- 	local shada_dir = vim.fn.stdpath("state") .. "/shada"
-- 	local lock_file = shada_dir .. "/oldfiles.lock"
--
-- 	-- Simple file lock
-- 	local max_attempts = 10
-- 	local attempt = 0
--
-- 	while attempt < max_attempts do
-- 		if vim.fn.filereadable(lock_file) == 0 then
-- 			-- Create lock
-- 			vim.fn.writefile({ tostring(vim.fn.getpid()) }, lock_file)
-- 			break
-- 		end
-- 		attempt = attempt + 1
-- 		vim.cmd("sleep 50m") -- Wait 50ms
-- 	end
--
-- 	if attempt >= max_attempts then
-- 		return -- Couldn't get lock
-- 	end
--
-- 	-- Now safely update
-- 	vim.cmd("rshada!")
-- 	local oldfiles = vim.list_slice(vim.v.oldfiles or {})
--
-- 	if #oldfiles == 0 or oldfiles[1] ~= current_file then
-- 		for i = #oldfiles, 1, -1 do
-- 			if oldfiles[i] == current_file then
-- 				table.remove(oldfiles, i)
-- 				break
-- 			end
-- 		end
--
-- 		table.insert(oldfiles, 1, current_file)
--
-- 		while #oldfiles > 10000 do
-- 			table.remove(oldfiles)
-- 		end
--
-- 		vim.v.oldfiles = oldfiles
-- 		vim.cmd("wshada!")
-- 	end
--
-- 	-- Release lock
-- 	vim.fn.delete(lock_file)
-- end
--
vim.opt.shada = "'10000,<100,s50,h,f1"
local oldfiles_group = vim.api.nvim_create_augroup("OldfilesPersistent", { clear = true })
--
-- -- Just ensure shada gets written when files are accessed
-- vim.api.nvim_create_autocmd("BufReadPost", {
-- 	group = oldfiles_group,
-- 	callback = safely_add_to_oldfiles,
-- })
--
local oldfiles_file = vim.fn.stdpath("state") .. "/custom_oldfiles.txt"

local function add_to_custom_oldfiles()
	local current_file = vim.fn.expand("%:p")

	if current_file == "" or vim.fn.filereadable(current_file) ~= 1 or vim.bo.buftype ~= "" then
		return
	end

	-- Read existing files
	local existing_files = {}
	if vim.fn.filereadable(oldfiles_file) == 1 then
		existing_files = vim.fn.readfile(oldfiles_file)
	end

	-- Remove if exists
	for i = #existing_files, 1, -1 do
		if existing_files[i] == current_file then
			table.remove(existing_files, i)
			break
		end
	end

	-- Add to front
	table.insert(existing_files, 1, current_file)

	-- Limit size
	while #existing_files > 10000 do
		table.remove(existing_files)
	end

	-- Write back
	vim.fn.writefile(existing_files, oldfiles_file)

	-- Also update vim's oldfiles for current session
	vim.v.oldfiles = existing_files
end

local function read_custom_oldfiles()
	if vim.fn.filereadable(oldfiles_file) == 1 then
		local custom_oldfiles = vim.fn.readfile(oldfiles_file)
		vim.v.oldfiles = custom_oldfiles
	end
end

-- Load custom oldfiles on startup
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = read_custom_oldfiles,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = oldfiles_group,
	callback = add_to_custom_oldfiles,
})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = oldfiles_group,
	callback = read_custom_oldfiles,
})
