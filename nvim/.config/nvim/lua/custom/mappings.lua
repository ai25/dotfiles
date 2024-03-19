---@type MappingsTable
local M = {}

M.general = {
  n = {
    --tmux
    ["<C-h>"] = { "<cmd>TmuxNavigateLeft<cr>", "Tmux Navigate Left" },
    ["<C-j>"] = { "<cmd>TmuxNavigateDown<cr>", "Tmux Navigate Down" },
    ["<C-k>"] = { "<cmd>TmuxNavigateUp<cr>", "Tmux Navigate Up" },
    ["<C-l>"] = { "<cmd>TmuxNavigateRight<cr>", "Tmux Navigate Right" },

    -- Configuration
    ["<leader>."] = { "+Config" },
    ["<leader>.l"] = { "<cmd>set nu!<cr>", "Toggle Line Numbers" },
    ["<leader>.r"] = { "<cmd>set rnu!<cr>", "Toggle Relative Numbers" },
    ["<leader>.u"] = { "<cmd>NvChadUpdate<cr>", "Update Nvchad" },
    ["<leader>.t"] = { "+Theme" },
    ["<leader>.tc"] = { "<cmd>Telescope themes<cr>", "Theme" },

    -- find
    ["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "Find Files" },
    ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "Find All" },
    ["<leader>fg"] = { "<cmd> Telescope live_grep <CR>", "Live Grep" },
    ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "Find Buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "Help Page" },
    ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "Find Oldfiles" },
    ["<leader>fk"] = { "<cmd> Telescope keymaps <CR>", "Show Keys" },

    ["<leader>p"] = { "<cmd>Telescope projects<cr>", "Projects" },
    ["<leader>t"] = { "<cmd>TroubleToggle<cr>", "Trouble" },
    ["<leader>wf"] = { "<cmd>let g:neovide_fullscreen=!g:neovide_fullscreen<cr>", "Toggle Fullscreen" },

    ["<leader>?"] = {
      function()
        require("telescope.builtin").oldfiles()
      end,
      "[?] Find recently opened files",
    },
    ["<leader><space>"] = {
      function()
        require("telescope.builtin").buffers()
      end,
      "[ ] Find existing buffers",
    },
    ["<leader>gf"] = {
      function()
        require("telescope.builtin").git_files()
      end,
      "Search [G]it [F]iles",
    },

    ["<leader>c"] = { "+Coding" },

    -- HOP around the screen with ease
    ["s"] = { "<cmd>HopChar2MW<cr>", "Hop anywhere" },

    -- Window navigation
    ["<C-right>"] = { "<C-w>l", "Window Right" },
    ["<C-left>"] = { "<C-w>h", "Window Left" },
    ["<C-up>"] = { "<C-w>k", "Window Up" },
    ["<C-down>"] = { "<C-w>j", "Window Down" },

    -- Formatting using Conform.nvim
    ["<leader>fm"] = { "<cmd>lua require('conform').format()<cr>", "Format" },
    ["<leader>cu"] = { "<cmd>lua require('conform').update()<cr>", "Update" },
  },
  v = {
    -- HOP around the screen with ease
    ["s"] = { "<cmd>HopChar2MW<cr>", "Hop anywhere" },
    ["S"] = { "<cmd>HopChar2MW<cr>", "Hop anywhere" },
  },
}

M.lspconfig = {
  n = {
    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "Code Action",
    },

    ["<leader>cd"] = {
      function()
        vim.diagnostic.open_float()
      end,
      "Floating Diagnostic",
    },

    ["gh"] = {
      function()
        vim.diagnostic.open_float()
      end,
      "[G]oto [H]over",
    },

    ["<leader>cr"] = {
      function()
        require("nvchad_ui.renamer").open()
      end,
      "Rename",
    },
  },
}

M.obsidian = {
  n = {
    ["<leader>oc"] = {
      function()
        require("obsidian").util.toggle_checkbox()
      end,
      "[O]bsidian [C]heckbox",
    },
    ["<leader>ot"] = {
      function()
        require("obsidian").util.toggle_task()
      end,
      "[O]bsidian [T]ask",
    },
    ["<leader>oo"] = { "<cmd>ObsidianOpen<cr>", "[O]bsidian [O]pen" },
    ["<leader>on"] = { "<cmd>ObsidianNew<cr>", "[O]bsidian [N]ew" },
    ["<leader>os"] = { "<cmd>ObsidianSearch<cr>", "[O]bsidian [S]earch" },
    ["<leader>ob"] = { "<cmd>ObsidianBacklinks<cr>", "[O]bsidian [B]acklinks" },
    ["<leader>ol"] = { "<cmd>ObsidianLinks<cr>", "[O]bsidian [L]inks" },
    ["<leader>od"] = { "<cmd>ObsidianDaily<cr>", "[O]bsidian [D]aily" },
    ["<leader>op"] = { "<cmd>ObsidianPreview<cr>", "[O]bsidian [P]review" },
  },
}

return M
