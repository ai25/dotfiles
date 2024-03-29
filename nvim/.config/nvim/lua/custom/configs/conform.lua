local options = {
	lsp_fallback = true,
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},

	formatters_by_ft = {
		lua = { "stylua" },

		javascript = { { "prettierd", "prettier" }, { "eslint_d", "eslint" } },
		typescript = { { "prettierd", "prettier" }, { "eslint_d", "eslint" } },
		javascriptreact = { { "prettierd", "prettier" }, { "eslint_d", "eslint" } },
		typescriptreact = { { "prettierd", "prettier" }, { "eslint_d", "eslint" } },

		css = { "prettier" },
		html = { "prettier" },

		sh = { "shfmt" },
		-- php
		php = { "phpcbf" },

		json = { "prettierd" },
		-- Use the "*" filetype to run formatters on all filetypes.
		["*"] = { "codespell" },
		-- Use the "_" filetype to run formatters on filetypes that don't
		-- have other formatters configured.
		["_"] = { "trim_whitespace" },
	},

	-- adding same formatter for multiple filetypes can look too much work for some
	-- instead of the above code you could just use a loop! the config is just a table after all!

	-- format_on_save = {
	--   -- These options will be passed to conform.format()
	--   timeout_ms = 500,
	--   lsp_fallback = true,
	-- },
}

require("conform").setup(options)
