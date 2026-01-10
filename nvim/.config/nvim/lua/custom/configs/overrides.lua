local M = {}
local mappings = require("custom.mappings")

M.treesitter = {
	ensure_installed = {
		"vim",
		"lua",
		"html",
		"css",
		"javascript",
		"typescript",
		"tsx",
		"c",
		"markdown",
		"markdown_inline",
		"php",
		"c_sharp",
		"cpp",
		"dart",
		"dockerfile",
		"jsdoc",
		"json",
		"kotlin",
		"nix",
		"prisma",
		"python",
		"rust",
		"scss",
		"svelte",
		"vue",
		"xml",
		"zig",
		"go",
	},
	indent = {
		enable = true,
		-- disable = {
		--   "python"
		-- },
	},
	highlight = {
		enable = true,

		disable = function(lang, buf)
			local max_filesize = 1000 * 1024 -- 1000 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
			return { "html", "markdown" }
		end,
	},
}

M.mason = {
	ensure_installed = {
		-- lua stuff
		"lua-language-server",
		"stylua",

		-- web dev stuff
		"angular-language-server",
		"astro-language-server",
		"css-lsp",
		"deno",
		"eslint_d",
		-- "eslint-lsp",
		-- "biome",
		"html-lsp",
		"prettierd",
		"rustywind",
		"stylelint",
		"typescript-language-server",
		"json-lsp",
		"tailwindcss",
		"tailwindcss-language-server",
		"tinymist",
		"marksman",
		"vscode-json-language-server",

		"markdownlint",
		"mdx-analyzer",
		"write-good",

		"htmx-lsp",

		"intelephense",
		-- "phpactor",
		"psalm",
		"phpcbf",

		-- c/cpp stuff
		"clangd",
		"clang-format",

		-- misc stuff
		"codespell",

		--python
		"basedpyright",
		"pylint",

		--go
		"gopls",
	},
}

-- git support in nvimtree
M.nvimtree = {
	git = {
		enable = true,
	},

	renderer = {
		highlight_git = true,
		icons = {
			show = {
				git = true,
			},
		},
	},
	actions = {
		remove_file = {
			close_window = true,
		},
	},
}

M.copilot = {
	-- Possible configurable fields can be found on:
	-- https://github.com/zbirenbaum/copilot.lua#setup-and-configuration
	suggestion = {
		enable = false,
	},
	panel = {
		enable = false,
	},
}

M.obsidian = {
	workspaces = {
		{
			name = "personal",
			path = "~/Shared Documents/",
		},
	},
	mappings = mappings.obsidian,

	-- see below for full list of options 👇
}

M.nvterm = {
	terminals = {
		shell = "zsh",
	},
}

---@type TailwindTools.Option
M.tailwind_tools = {
	document_color = {
		enabled = true, -- can be toggled by commands
		kind = "inline", -- "inline" | "foreground" | "background"
		inline_symbol = "󰝤 ", -- only used in inline mode
		debounce = 200, -- in milliseconds, only applied in insert mode
	},
	conceal = {
		enabled = false, -- can be toggled by commands
		min_length = nil, -- only conceal classes exceeding the provided length
		symbol = "󱏿", -- only a single character is allowed
		highlight = { -- extmark highlight options, see :h 'highlight'
			fg = "#38BDF8",
		},
	},
	custom_filetypes = {}, -- see the extension section to learn how it works
	cmp = {
		highlight = "foreground", -- color preview style, "foreground" | "background"
	},
	telescope = {
		utilities = {
			callback = function(name, class) end, -- callback used when selecting an utility class in telescope
		},
	},
	-- see the extension section to learn more
	extension = {
		queries = {}, -- a list of filetypes having custom `class` queries
		patterns = { -- a map of filetypes to Lua pattern lists
			-- example:
			-- rust = { "class=[\"']([^\"']+)[\"']" },
			-- javascript = { "clsx%(([^)]+)%)" },
		},
	},
}

return M
