local cmp = require("cmp")
local lspkind = require("lspkind")
local options = {
	mapping = {
		["<C-y>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		}),
		["<C-Space>"] = cmp.mapping.complete(),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "nvim_lua" },
		{ name = "path" },
		{ name = "yanky" }, -- Add yanky as a completion source
		-- { name = "tailwindcss" },
	},
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text",
			menu = {
				nvim_lsp = "[LSP]",
				luasnip = "[Snippet]",
				buffer = "[Buffer]",
				nvim_lua = "[Lua]",
				path = "[Path]",
				yanky = "[Yanky]", -- Add yanky to menu
				-- tailwindcss = "[Tailwind]",
			},
			before = function(entry, vim_item)
				-- First apply tailwind formatting if available
				if require("tailwind-tools.cmp").lspkind_format then
					vim_item = require("tailwind-tools.cmp").lspkind_format(entry, vim_item)
				end

				-- Then handle yanky entries specially
				if entry.source.name == "yanky" then
					vim_item.kind = "󰅌 Yanky" -- Using a clipboard icon
				end

				return vim_item
			end,
		}),
	},
}

return options
