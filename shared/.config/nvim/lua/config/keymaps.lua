-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>sG", function()
  local root = require("lazyvim.util").root.get()
  require("fzf-lua").live_grep({
    cwd = root,
    rg_opts = table.concat({
      "--column",
      "--line-number",
      "--no-heading",
      "--color=always",
      "--smart-case",
      "--hidden",
      "--no-ignore",
    }, " "),
  })
end, { desc = "Grep (root, incl. hidden + ignored)" })

-- -- mini.align keymaps
-- vim.keymap.set("x", "ga", function()
--   require("mini.align").align()
-- end, { desc = "Align selection" })
--
-- vim.keymap.set("n", "ga", function()
--   require("mini.align").operator()
-- end, { desc = "Align operator" })
