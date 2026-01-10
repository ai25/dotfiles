local overrides = require("custom.configs.overrides")

---@param bufnr integer
---@param ... string
---@return string
local function first(bufnr, ...)
	local conform = require("conform")
	for i = 1, select("#", ...) do
		local formatter = select(i, ...)
		if conform.get_formatter_info(formatter, bufnr).available then
			return formatter
		end
	end
	return select(1, ...)
end

---@type NvPluginSpec[]
local plugins = {
	{
		"nvim-lua/plenary.nvim",
		lazy = false,
	},
	-- {
	-- 	"nvim-telescope/telescope.nvim",
	-- 	dependencies = { "nvim-treesitter/nvim-treesitter" },
	-- 	cmd = "Telescope",
	-- 	init = function()
	-- 		require("core.utils").load_mappings("telescope")
	-- 	end,
	-- 	opts = function()
	-- 		return require("plugins.configs.telescope")
	-- 	end,
	-- 	config = function(_, opts)
	-- 		dofile(vim.g.base46_cache .. "telescope")
	-- 		local telescope = require("telescope")
	-- 		telescope.setup(opts)
	--
	-- 		-- load extensions
	-- 		for _, ext in ipairs(opts.extensions_list) do
	-- 			telescope.load_extension(ext)
	-- 		end
	-- 	end,
	-- },

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

	-- {
	-- 	"max397574/better-escape.nvim",
	-- 	event = "InsertEnter",
	-- 	config = function()
	-- 		require("better_escape").setup()
	-- 	end,
	-- },

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>fm",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		-- This will provide type hinting with LuaLS
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = function(bufnr)
					return {
						first(bufnr, "prettierd", "prettier"),
					}
				end,
				typescript = function(bufnr)
					return {
						first(bufnr, "prettierd", "prettier"),
					}
				end,
				javascriptreact = function(bufnr)
					return {
						first(bufnr, "prettierd", "prettier"),
					}
				end,
				typescriptreact = function(bufnr)
					return {
						first(bufnr, "prettierd", "prettier"),
					}
				end,
				css = { "prettier" },
				html = { "prettier" },
				sh = { "shfmt" },
				php = { "phpcbf" },
				json = { "prettierd" },
				kotlin = { "ktlint" },
				-- Use the "*" filetype to run formatters on all filetypes
				-- ["*"] = { "codespell" },
				-- Use the "_" filetype to run formatters on filetypes that don't
				-- have other formatters configured
				["_"] = { "trim_whitespace" },
			},
			-- Set default options
			default_format_opts = {
				lsp_format = "fallback",
			},
			-- Set up format-on-save
			format_on_save = { timeout_ms = 500 },
			-- Customize formatters
			formatters = {
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
		},
		init = function()
			-- If you want the formatexpr, here is the place to set it
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
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
	-- {
	-- 	"onsails/lspkind.nvim",
	-- 	lazy = false,
	-- 	priority = 1000, -- Add high priority to ensure it loads early
	-- },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"onsails/lspkind.nvim",
			{ "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
			"tailwind-tools.nvim",
		},
		opts = function()
			return require("custom.configs.cmp")
		end,
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
	-- {
	-- 	"numToStr/Comment.nvim",
	-- 	dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
	-- 	config = function()
	-- 		require("Comment").setup({
	-- 			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
	-- 		})
	-- 	end,
	-- },

	{
		"karb94/neoscroll.nvim",
		keys = {
			"<C-u>",
			"<C-d>",
			"<C-b>",
			"<C-f>",
			"zt",
			"zz",
			"zb",
		},
		config = function()
			require("neoscroll").setup({
				mappings = { -- Keys to be mapped to their corresponding default scrolling animation
					"<C-u>",
					"<C-d>",
					"<C-b>",
					"<C-f>",
					"zt",
					"zz",
					"zb",
				},
			})
		end,
	},
	{
		"mhinz/vim-startify",
		lazy = false,
		config = function()
			-- require("custom.configs.startify")
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
		lazy = false,
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
		opts = {
			user_default_options = {
				tailwind = true,
			},
		},
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

	-- -- Git Signs
	-- {
	-- 	"lewis6991/gitsigns.nvim",
	-- 	event = "BufRead",
	-- 	config = function()
	-- 		require("gitsigns").setup()
	-- 	end,
	-- },

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
	-- This is one word under Vim's definition:
	--
	-- CamelCaseACRONYMWords_underscore1234
	-- w--------------------------------->w
	-- e--------------------------------->e
	-- b<---------------------------------b
	-- With this plugin, this becomes six words:
	--
	-- CamelCaseACRONYMWords_underscore1234
	-- w--->w-->w----->w---->w-------->w->w
	-- e-->e-->e----->e--->e--------->e-->e
	-- b<---b<--b<-----b<----b<--------b<-b
	--
	-- word definitions
	-- A word (lowercase) is any of the following:
	--
	-- word	Example
	-- Camel case words	[Camel][Case]
	-- Acronyms	[HTML]And[CSS]
	-- Uppercase words	[UPPERCASE] [WORDS]
	-- Lowercase words	[lowercase] [words]
	-- Hex color codes	[#0f0f0f]
	-- Hex literals	[0x00ffFF] [0x0f]
	-- Octal literals	[0o644] [0o0755]
	-- Binary literals	[0b01] [0b0011]
	-- Regular numbers	[1234] [5678]
	-- Other characters	[~!@#$]

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

	{
		"lambdalisue/suda.vim",
		event = "VeryLazy",
	},

	-- Neogit
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			"nvim-telescope/telescope.nvim", -- optional
		},
		config = function()
			require("custom.configs.neogit")
		end,
	},

	{
		"luckasRanarison/tailwind-tools.nvim",
		lazy = false,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = overrides.tailwind_tools,
	},

	{
		"elkowar/yuck.vim",
		event = "VeryLazy",
	},

	--   Mappings
	-- The following default mappings are included:
	--
	--     mx              Set mark x
	--     m,              Set the next available alphabetical (lowercase) mark
	--     m;              Toggle the next available mark at the current line
	--     dmx             Delete mark x
	--     dm-             Delete all marks on the current line
	--     dm<space>       Delete all marks in the current buffer
	--     m]              Move to next mark
	--     m[              Move to previous mark
	--     m:              Preview mark. This will prompt you for a specific mark to
	--                     preview; press <cr> to preview the next mark.
	--
	--     m[0-9]          Add a bookmark from bookmark group[0-9].
	--     dm[0-9]         Delete all bookmarks from bookmark group[0-9].
	--     m}              Move to the next bookmark having the same type as the bookmark under
	--                     the cursor. Works across buffers.
	--     m{              Move to the previous bookmark having the same type as the bookmark under
	--                     the cursor. Works across buffers.
	--     dm=             Delete the bookmark under the cursor.
	--
	-- {
	-- 	"chentoast/marks.nvim",
	-- 	lazy = false,
	-- 	opts = {},
	-- 	config = function()
	-- 		require("custom.configs.marks")
	-- 	end,
	-- },
	-- yanky.nvim - Enhanced yank and put functionality for Neovim
	--
	-- Features:
	-- * Yank history with cycling through previous yanks
	-- * Preserves cursor position when yanking
	-- * Highlights yanked and put text
	-- * Enhanced put operations with special behaviors
	-- * Text objects for yanked content
	-- * Telescope integration for browsing yank history
	--
	-- Key mappings:
	-- * y           - Yank with preserved cursor position
	-- * p/P         - Put after/before cursor with yank history support
	-- * gp/gP       - Put after/before and position cursor after the text
	-- * <Alt-p>/<Alt-n> - Cycle through previous/next yank in history
	-- * <leader>fy  - Open yank history in Telescope
	-- * [y/]y       - Put before/after with proper indentation
	-- * <y/>y       - Put with decreased/increased indentation
	-- * =y          - Put with auto-formatting
	-- * iy          - Text object for the last put text
	{
		"gbprod/yanky.nvim",
		event = "BufRead",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			{
				"chrisgrieser/cmp_yanky",
				dependencies = { "hrsh7th/nvim-cmp" },
			},
		},
		config = function()
			require("custom.configs.yanky")
		end,
	},

	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		event = "VeryLazy",
		config = function()
			require("mcphub").setup({})
		end,
	},
	{
		"yetone/avante.nvim",
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make", -- ⚠️ must add this line! ! !
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		config = function()
			require("custom.configs.avante")
		end,
	},

	{
		"echasnovski/mini.align",
		event = "BufRead",
		version = "*",
		config = function()
			require("mini.align").setup()
		end,
	},
	{
		"echasnovski/mini.comment",
		event = "BufRead",
		version = "*",
		config = function()
			require("mini.comment").setup()
		end,
	},
	{
		"echasnovski/mini.cursorword",
		event = "BufRead",
		version = "*",
		config = function()
			require("mini.cursorword").setup()
		end,
	},
	{
		"echasnovski/mini.hipatterns",
		event = "BufRead",
		version = "*",
		config = function()
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

					-- Highlight hex color strings (`#rrggbb`) using that color
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})
		end,
	},
	{
		"echasnovski/mini.indentscope",
		event = "BufRead",
		version = "*",
		config = function()
			require("mini.indentscope").setup()
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		opts = {},
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("codecompanion").setup({
				strategies = {
					chat = {
						adapter = "ollama",
						-- model = "gemma3n:e4b",
						model = "qwen3:0.6b",
					},
					inline = {
						adapter = "ollama",
						-- model = "gemma3n:e4b",
						model = "qwen3:0.6b",
					},
				},
				adapters = {
					-- ollama = function()
					-- 	return require("codecompanion.adapters").extend("ollama", {
					-- 		env = {
					-- 			url = "http://localhost:8080",
					-- 		},
					-- 	})
					-- end,
				},
			})
		end,
	},
	-- {
	-- 	"xiyaowong/transparent.nvim",
	-- 	lazy = false,
	-- 	config = function()
	-- 		require("transparent").setup({
	-- 			groups = { -- Default groups to clear
	-- 				"Normal",
	-- 				"NormalNC",
	-- 				"Comment",
	-- 				"Constant",
	-- 				"Special",
	-- 				"Identifier",
	-- 				"Statement",
	-- 				"PreProc",
	-- 				"Type",
	-- 				"Underlined",
	-- 				"Todo",
	-- 				"String",
	-- 				"Function",
	-- 				"Conditional",
	-- 				"Repeat",
	-- 				"Operator",
	-- 				"Structure",
	-- 				"LineNr",
	-- 				"NonText",
	-- 				"SignColumn",
	-- 				"CursorLine",
	-- 				"CursorLineNr",
	-- 				"StatusLine",
	-- 				"StatusLineNC",
	-- 				"EndOfBuffer",
	-- 			},
	-- 			extra_groups = { "NvimTreeNormal", "NvimTreeNormalNC" }, -- Include NvimTree highlight groups
	-- 			exclude_groups = {}, -- Groups you don't want to clear
	-- 		})
	-- 	end,
	-- },
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && cmake --build build --config Release",
	},
}

return plugins
