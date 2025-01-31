local overrides = require("custom.configs.overrides")

---@type NvPluginSpec[]
local plugins = {

	-- Override plugin definition options
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.configs.lspconfig")
			require("custom.configs.lspconfig")
		end, -- Override to setup mason-lspconfig
	},

	-- override plugin configs
	{
		"williamboman/mason.nvim",
		opts = overrides.mason,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = overrides.treesitter,
	},

	{
		"nvim-tree/nvim-tree.lua",
		opts = overrides.nvimtree,
	},

	-- Install a plugin
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		config = function()
			require("better_escape").setup()
		end,
	},

	{
		"stevearc/conform.nvim",
		--  for users those who want auto-save conform + lazyloading!
		-- event = "BufWritePre"
		config = function()
			require("custom.configs.conform")
		end,
	},
	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	-- Lazy load when event occurs. Events are triggered
	-- 	-- as mentioned in:
	-- 	-- https://vi.stackexchange.com/a/4495/20389
	-- 	event = "InsertEnter",
	-- 	-- You can also have it load at immediately at
	-- 	-- startup by commenting above and uncommenting below:
	-- 	-- lazy = false
	-- 	opts = overrides.copilot,
	-- },
	{
		"hrsh7th/nvim-cmp",
		opts = require("custom.configs.cmp"),
	},

	{
		"evanleck/vim-svelte",
		ft = "svelte",
	},

	{
		"ahmedkhalf/project.nvim",
		after = "telescope.nvim",
		config = function()
			require("project_nvim").setup({})
			local t = require("telescope")
			t.load_extension("projects")
		end,
	},
	{
		"numToStr/Comment.nvim",
		dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
		config = function()
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	},

	{
		"karb94/neoscroll.nvim",
		keys = { "<C-d>", "<C-u>" },
		config = function()
			require("neoscroll").setup()
		end,
	},
	{
		"mhinz/vim-startify",
		lazy = false,
		config = function()
			-- require("custom.configs.startify")
		end,
	},
	{
		"mfussenegger/nvim-lint",
		lazy = false,
		config = function()
			require("lint").linters_by_ft = {
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				lua = { "luacheck" },
				-- css
				css = { "stylelint" },
				scss = { "stylelint" },
				sass = { "stylelint" },
				less = { "stylelint" },
			}
			vim.api.nvim_set_keymap(
				"v",
				"<C-c>",
				'<Esc>:lua require("lint").try_lint()<CR>',
				{ noremap = true, silent = true }
			)

			vim.api.nvim_set_keymap(
				"i",
				"<C-c>",
				'<Esc>:lua require("lint").try_lint()<CR>',
				{ noremap = true, silent = true }
			)
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},

	-- {
	-- 	"epwalsh/obsidian.nvim",
	-- 	version = "*", -- recommended, use latest release instead of latest commit
	-- 	lazy = false,
	-- 	ft = "markdown",
	-- 	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- 	-- event = {
	-- 	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	-- 	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
	-- 	--   "BufReadPre path/to/my-vault/**.md",
	-- 	--   "BufNewFile path/to/my-vault/**.md",
	-- 	-- },
	-- 	dependencies = {
	-- 		-- Required.
	-- 		"nvim-lua/plenary.nvim",
	--
	-- 		-- see below for full list of optional dependencies 👇
	-- 	},
	-- 	opts = overrides.obsidian,
	-- },

	-- helpful for jsx and html
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({
				autotag = { enable = true },
			})
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	},
	--autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equalent to setup({}) function
	},

	-- All NvChad plugins are lazy-loaded by default
	-- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
	-- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example

	--   select words with Ctrl-N (like Ctrl-d in Sublime Text/VS Code)
	-- create cursors vertically with Ctrl-Down/Ctrl-Up
	-- select one character at a time with Shift-Arrows
	-- press n/N to get next/previous occurrence
	-- press [/] to select next/previous cursor
	-- press q to skip current and get next occurrence
	-- press Q to remove current cursor/selection
	-- start insert mode with i,a,I,A
	--
	{
		"mg979/vim-visual-multi",
		lazy = false,
	},

	--Surround:
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- Targets.vim is a Vim plugin that adds various text objects to give you more targets to operate on. It expands on the idea of simple commands like di' (delete inside the single quotes around the cursor) to give you more opportunities to craft powerful commands that can be repeated reliably. One major goal is to handle all corner cases correctly.

	{
		"wellle/targets.vim",
		event = "VeryLazy",
	},

	-- Extended matching for %
	{
		"adelarsq/vim-matchit",
		event = "VeryLazy",
		config = function()
			vim.cmd([[packadd! matchit]])
		end,
	},

	-- Git Blame
	{
		"f-person/git-blame.nvim",
		event = "VeryLazy",
	},

	-- Git Signs
	{
		"lewis6991/gitsigns.nvim",
		event = "BufRead",
		config = function()
			require("gitsigns").setup()
		end,
	},

	-- Sneak
	-- Sneak is invoked with s followed by exactly two characters:

	-- s{char}{char}
	-- Type sab to move the cursor immediately to the next instance of the text "ab".
	-- Additional matches, if any, are highlighted until the cursor is moved.
	-- Type ; to go to the next match (or s again, if s_next is enabled; see :help sneak).
	-- Type 3; to skip to the third match from the current position.
	-- Type ctrl-o or `` to go back to the starting point.
	-- This is a built-in Vim motion; Sneak adds to Vim's jumplist only on s invocation—not repeats—so you can abandon a trail of ; or , by a single ctrl-o or ``.
	-- Type s<Enter> at any time to repeat the last Sneak-search.
	-- Type S to search backwards.
	--
	{
		"justinmk/vim-sneak",
		event = "BufRead",
		config = function()
			vim.cmd([[let g:sneak#label = 1]])
			-- ignore case for sneak
			vim.cmd([[let g:sneak#use_ic_scs = 1]])
		end,
	},

	-- Quick Scope
	{
		"unblevable/quick-scope",
		event = "BufRead",
		config = function()
			vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
		end,
	},

	-- word motions
	{
		"chaoren/vim-wordmotion",
		event = "BufRead",
	},

	-- Undo Tree
	{
		"mbbill/undotree",
		event = "BufRead",
	},

	-- Move lines and blocks of text via (alt) j/k
	{
		"matze/vim-move",
		event = "BufRead",
	},

	-- Lets you use `:W` to sudo write a file
	{
		"lambdalisue/suda.vim",
		event = "BufRead",
	},

	-- Neogit
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			"nvim-telescope/telescope.nvim", -- optional
		},
		config = true,
	},
}

return plugins
