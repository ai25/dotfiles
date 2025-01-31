local cmp = require("cmp")
local options = {
	mapping = {
		["<C-y>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		}),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "nvim_lua" },
		{ name = "path" },
	},
	dependencies = {
		-- {
		-- 	"zbirenbaum/copilot-cmp",
		-- 	config = function()
		-- 		require("copilot_cmp").setup()
		-- 	end,
		-- },
	},
}

return options
