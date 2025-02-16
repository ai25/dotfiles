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
		-- { name = "tailwindcss" },
	},
	formatting = {
		format = lspkind.cmp_format({
			before = require("tailwind-tools.cmp").lspkind_format,
		}),
	},
}

return options
