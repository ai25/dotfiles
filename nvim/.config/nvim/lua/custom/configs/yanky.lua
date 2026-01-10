local function setup()
	require("yanky").setup({
		ring = {
			history_length = 100,
			storage = "shada",
			sync_with_numbered_registers = true,
			cancel_event = "update",
			ignore_registers = { "_" },
			update_register_on_cycle = false,
		},
		picker = {
			select = {
				action = nil,
			},
			telescope = {
				use_default_mappings = true,
				mappings = nil,
			},
		},
		system_clipboard = {
			sync_with_ring = true,
		},
		highlight = {
			on_put = true,
			on_yank = true,
			timer = 500,
		},
		preserve_cursor_position = {
			enabled = true,
		},
		textobj = {
			enabled = true,
		},
	})

	-- Load telescope extension
	require("telescope").load_extension("yank_history")
	pcall(function()
		require("cmp").register_source("yanky", require("cmp_yanky").new())
	end)
end

setup()
