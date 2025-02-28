local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		source = "always",
		border = "rounded",
		header = "",
	},
})

-- Define signs for diagnostics
local signs = {
	Error = " ",
	Warn = " ",
	Hint = " ",
	Info = " ",
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- if you just want default config for the servers then put them in a table
-- set up for web development (html, css, js, ts, react, vue, svelte, php, wordpress)
local servers = {
	"html",
	"cssls",
	"ts_ls",
	"clangd",
	"vimls",
	"yamlls",
	"intelephense",
	"svelte",
	"vuels",
	"tailwindcss",
	-- "graphql",
	"dockerls",
	"bashls",
	"jsonls",
	-- "eslint",
	"stylelint_lsp",
	"psalm",
	"angularls",
	"astro",
	"rust_analyzer",
}

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

lspconfig.pyright.setup({
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					ignore = { "W391" },
					maxLineLength = 100,
				},
			},
		},
	},
})

lspconfig.ts_ls.setup({
	on_attach = function(client, bufnr)
		-- Disable tsserver formatting in favor of eslint
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		on_attach(client, bufnr)
	end,
	capabilities = capabilities,
	root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json"),
})

lspconfig.stylelint_lsp.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		stylelintplus = {
			autoFixOnFormat = true,
		},
	},
})

lspconfig.eslint.setup({
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
		"svelte",
	},
	settings = {
		workingDirectories = { mode = "auto" },
	},
})

-- Add a command to force diagnostics refresh
vim.api.nvim_create_user_command("RefreshDiagnostics", function()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.diagnostic.reset(bufnr)
	for _, client in pairs(vim.lsp.get_active_clients({ bufnr = bufnr })) do
		if client.name == "eslint" then
			client.request("textDocument/diagnostic", {
				textDocument = vim.lsp.util.make_text_document_params(bufnr),
			}, nil, bufnr)
		end
	end
end, {})

lspconfig.cssls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		css = {
			validate = true,
		},
	},
})
lspconfig.jsonls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "vscode-json-languageserver", "--stdio" },
})

-- lspconfig.phpactor.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   settings = {
--     phpactor = {
--       path = "phpactor",
--     },
--   },
-- }

lspconfig.intelephense.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		intelephense = {
			format = {
				enable = true,
			},
			stubs = {
				"apache",
				"bcmath",
				"bz2",
				"calendar",
				"com_dotnet",
				"Core",
				"ctype",
				"curl",
				"date",
				"dba",
				"dom",
				"enchant",
				"exif",
				"FFI",
				"fileinfo",
				"filter",
				"fpm",
				"ftp",
				"gd",
				"gettext",
				"gmp",
				"hash",
				"iconv",
				"imap",
				"intl",
				"json",
				"ldap",
				"libxml",
				"mbstring",
				"meta",
				"mysqli",
				"oci8",
				"odbc",
				"openssl",
				"pcntl",
				"pcre",
				"PDO",
				"pdo_ibm",
				"pdo_mysql",
				"pdo_pgsql",
				"pdo_sqlite",
				"pgsql",
				"Phar",
				"posix",
				"pspell",
				"readline",
				"Reflection",
				"session",
				"shmop",
				"SimpleXML",
				"snmp",
				"soap",
				"sockets",
				"sodium",
				"SPL",
				"sqlite3",
				"standard",
				"superglobals",
				"sysvmsg",
				"sysvsem",
				"sysvshm",
				"tidy",
				"tokenizer",
				"xml",
				"xmlreader",
				"xmlrpc",
				"xmlwriter",
				"xsl",
				"Zend OPcache",
				"zip",
				"zlib",
				"wordpress",
			},
		},
	},
})
