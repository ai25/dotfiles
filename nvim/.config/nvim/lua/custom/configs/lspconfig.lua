local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")

-- if you just want default config for the servers then put them in a table
-- set up for web development (html, css, js, ts, react, vue, svelte, php, wordpress)
local servers = {
	"html",
	"cssls",
	"tsserver",
	"clangd",
	"vimls",
	"yamlls",
	"intelephense",
	"svelte",
	"vuels",
	"tailwindcss",
	"graphql",
	"dockerls",
	"bashls",
	"jsonls",
	"eslint",
	"stylelint_lsp",
	"psalm",
	"angularls",
	"astro",
	"denols",
	"rust_analyzer",
}

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

--
-- eslint, prettier, stylelint
local eslint = {
	lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
	lintIgnoreExitCode = true,
	lintStdin = true,
	lintFormats = { "%f:%l:%c: %m" },
	formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
	formatStdin = true,
}

local prettier = {
	formatCommand = "prettier --stdin-filepath ${INPUT}",
	formatStdin = true,
}

local stylelint = {
	lintCommand = "stylelint_lsp --stdin --stdin-filename ${INPUT}",
	lintIgnoreExitCode = true,
	lintStdin = true,
	lintFormats = { "%f:%l:%c: %m" },
	formatCommand = "stylelint_lsp --fix --stdin --stdin-filename ${INPUT}",
	formatStdin = true,
}

lspconfig.tsserver.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	init_options = { documentFormatting = true },
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
	settings = {
		rootMarkers = { ".git/" },
		languages = {
			javascript = { eslint, prettier },
			javascriptreact = { eslint, prettier },
			typescript = { eslint, prettier },
			typescriptreact = { eslint, prettier },
			css = { prettier, stylelint },
			scss = { prettier, stylelint },
			html = { prettier },
		},
	},
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
	cmd = { "eslint_d", "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
	on_attach = on_attach,
	capabilities = capabilities,
	-- Add additional configurations if needed
})
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
