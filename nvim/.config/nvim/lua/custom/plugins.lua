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
	{
		"zbirenbaum/copilot.lua",
		-- Lazy load when event occurs. Events are triggered
		-- as mentioned in:
		-- https://vi.stackexchange.com/a/4495/20389
		event = "InsertEnter",
		-- You can also have it load at immediately at
		-- startup by commenting above and uncommenting below:
		-- lazy = false
		opts = overrides.copilot,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{
				"zbirenbaum/copilot-cmp",
				config = function()
					require("copilot_cmp").setup()
				end,
			},
		},
		opts = {
			sources = {
				{ name = "copilot", group_index = 2 },
				{ name = "nvim_lsp", group_index = 2 },
				{ name = "luasnip", group_index = 2 },
				{ name = "buffer", group_index = 2 },
				{ name = "nvim_lua", group_index = 2 },
				{ name = "path", group_index = 2 },
			},
		},
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

	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		lazy = false,
		ft = "markdown",
		-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
		-- event = {
		--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
		--   "BufReadPre path/to/my-vault/**.md",
		--   "BufNewFile path/to/my-vault/**.md",
		-- },
		dependencies = {
			-- Required.
			"nvim-lua/plenary.nvim",

			-- see below for full list of optional dependencies 👇
		},
		opts = overrides.obsidian,
	},

	-- helpful for jsx and html
	{
		"windwp/nvim-ts-autotag",
		ft = { "typescript", "typescriptreact", "html", "svelte", "vue", "javascript", "javascriptreact" },
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
	-- To make a plugin not be loaded
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   enabled = false
	-- },

	-- All NvChad plugins are lazy-loaded by default
	-- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
	-- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
	-- {
	--   "mg979/vim-visual-multi",
	--   lazy = false,
	-- }
}

return plugins
