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
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
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
		"cssls",
		"ts_ls",
		"tailwindcss",
		"tailwindcss-language-server",
		"tinymist",
		"marksman",

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
		"python-lsp-server",
		"pyright",
		"pylint",
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

return M

