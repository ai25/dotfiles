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

-- Create a custom on_attach that includes diagnostic handling
local custom_on_attach = function(client, bufnr)
	-- Call the original on_attach
	on_attach(client, bufnr)

	-- Set up diagnostic keymaps
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Previous Diagnostic" })
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next Diagnostic" })
	vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { buffer = bufnr, desc = "Show Diagnostic" })

	-- Enable diagnostics for this buffer
	vim.diagnostic.enable(bufnr)
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
	"pylsp",
}

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
	})
end

-- lspconfig.ts_ls.setup({
-- 	on_attach = on_attach,
-- 	capabilities = capabilities,
-- 	init_options = { documentFormatting = true },
-- 	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
-- 	settings = {
-- 		rootMarkers = { ".git/" },
-- 		languages = {
-- 			javascript = { eslint, prettier },
-- 			javascriptreact = { eslint, prettier },
-- 			typescript = { eslint, prettier },
-- 			typescriptreact = { eslint, prettier },
-- 			css = { prettier, stylelint },
-- 			scss = { prettier, stylelint },
-- 			html = { prettier },
-- 		},
-- 	},
-- })

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

-- lspconfig.tailwindcss.setup({
-- 	cmd = { "tailwindcss-language-server", "--stdio" },
-- 	filetypes = {
-- 		"html",
-- 		"css",
-- 		"scss",
-- 		"javascript",
-- 		"javascriptreact",
-- 		"typescript",
-- 		"typescriptreact",
-- 		"vue",
-- 		"svelte",
-- 	},
-- 	root_dir = lspconfig.util.root_pattern("tailwind.config.js", "package.json"),
-- 	settings = {},
-- })

-- lspconfig.eslint.setup({
--     on_attach = function(client, bufnr)
--         custom_on_attach(client, bufnr)
--
--         -- Enable autofix on save
--         vim.api.nvim_create_autocmd("BufWritePre", {
--             buffer = bufnr,
--             command = "EslintFixAll",
--         })
--
--         -- Force diagnostics update after attach
--         vim.api.nvim_create_autocmd({"BufEnter", "BufWritePre", "InsertLeave"}, {
--             buffer = bufnr,
--             callback = function()
--                 vim.diagnostic.enable(bufnr)
--                 client.request("textDocument/diagnostic", {
--                     textDocument = vim.lsp.util.make_text_document_params(bufnr)
--                 }, nil, bufnr)
--             end,
--         })
--     end,
--     capabilities = capabilities,
--     settings = {
--         workingDirectories = { mode = "auto" },
--         validate = "on",
--         packageManager = "npm",
--         useESLintClass = true,
--         experimental = {
--             useFlatConfig = true
--         },
--         format = true,
--     },
--     root_dir = lspconfig.util.root_pattern("eslint.config.js", ".eslintrc.js", ".eslintrc.json"),
--     handlers = {
--         ["textDocument/publishDiagnostics"] = vim.lsp.with(
--             vim.lsp.diagnostic.on_publish_diagnostics, {
--                 -- Enable virtual text
--                 virtual_text = true,
--                 -- Show signs
--                 signs = true,
--                 -- Update in insert mode
--                 update_in_insert = false,
--                 -- Set severity sorting
--                 severity_sort = true,
--             }
--         ),
--     },
-- })

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

-- Debug function to check ESLint status
vim.api.nvim_create_user_command("EslintDebug", function()
	-- Get active clients
	local active_clients = vim.lsp.get_active_clients()
	local eslint_client = nil

	-- Find ESLint client
	for _, client in ipairs(active_clients) do
		if client.name == "eslint" then
			eslint_client = client
			break
		end
	end

	-- Print debug info
	if eslint_client then
		print("ESLint client found:")
		print("  - ID: " .. eslint_client.id)
		print("  - Name: " .. eslint_client.name)
		print("  - Root directory: " .. eslint_client.config.root_dir)
		print("  - Attached buffers: " .. vim.inspect(eslint_client.attached_buffers))
	else
		print("No ESLint client found!")
	end

	-- Check eslint_d
	local eslint_d_handle = io.popen("which eslint_d")
	local eslint_d_path = eslint_d_handle:read("*a")
	eslint_d_handle:close()

	print("\nESLint_d path: " .. eslint_d_path)

	-- Check configuration
	local config_handle = io.popen("eslint_d --print-config " .. vim.api.nvim_buf_get_name(0))
	local config_output = config_handle:read("*a")
	config_handle:close()

	print("\nESLint configuration:")
	print(config_output)
end, {})

-- Add these debug commands
vim.api.nvim_create_user_command("LspClients", function()
	local clients = vim.lsp.get_active_clients()
	for _, client in ipairs(clients) do
		print(string.format("Client: %s, ID: %d", client.name, client.id))
		print("  Attached buffers:")
		for bufnr, _ in pairs(client.attached_buffers) do
			local buf_name = vim.api.nvim_buf_get_name(bufnr)
			print(string.format("    - Buffer %d: %s", bufnr, buf_name))
		end
	end
end, {})

vim.api.nvim_create_user_command("EslintStatus", function()
	-- Check eslint_d installation
	local eslint_d_check = vim.fn.system("which eslint_d")
	print("eslint_d location: " .. eslint_d_check)

	-- Check if current buffer should have eslint
	local current_ft = vim.bo.filetype
	print("Current filetype: " .. current_ft)

	-- Check for config files
	local config_files = {
		"eslint.config.js",
		".eslintrc.js",
		".eslintrc.json",
		".eslintrc",
	}

	print("Checking for ESLint config files:")
	for _, file in ipairs(config_files) do
		if vim.fn.findfile(file, ".;") ~= "" then
			print("  Found: " .. file)
		end
	end

	-- Test eslint_d directly
	local current_file = vim.api.nvim_buf_get_name(0)
	local eslint_test = vim.fn.system("eslint_d " .. current_file)
	print("\nESLint_d test output:")
	print(eslint_test)
end, {})

-- Testing command to manually start ESLint
vim.api.nvim_create_user_command("StartEslint", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local client_id = vim.lsp.start({
		name = "eslint",
		cmd = { "eslint_d", "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
		root_dir = vim.fn.getcwd(),
	})
	if client_id then
		vim.lsp.buf_attach_client(bufnr, client_id)
		print("ESLint client started and attached")
	else
		print("Failed to start ESLint client")
	end
end, {})
