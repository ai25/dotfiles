---@type MappingsTable
local M = {}

M.general = {
	n = {
		--tmux
		["<C-h>"] = { "<cmd>TmuxNavigateLeft<cr>", "Tmux Navigate Left" },
		["<C-j>"] = { "<cmd>TmuxNavigateDown<cr>", "Tmux Navigate Down" },
		["<C-k>"] = { "<cmd>TmuxNavigateUp<cr>", "Tmux Navigate Up" },
		["<C-l>"] = { "<cmd>TmuxNavigateRight<cr>", "Tmux Navigate Right" },

		-- Configuration
		["<leader>."] = { "+Config" },
		["<leader>.l"] = { "<cmd>set nu!<cr>", "Toggle Line Numbers" },
		["<leader>.r"] = { "<cmd>set rnu!<cr>", "Toggle Relative Numbers" },
		["<leader>.u"] = { "<cmd>NvChadUpdate<cr>", "Update Nvchad" },
		["<leader>.t"] = { "+Theme" },
		["<leader>.tc"] = { "<cmd>Telescope themes<cr>", "Theme" },

		-- find
		["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "Find Files" },
		["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "Find All" },
		["<leader>fg"] = { "<cmd> Telescope live_grep <CR>", "Live Grep" },
		["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "Find Buffers" },
		["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "Help Page" },
		["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "Find Oldfiles" },
		["<leader>fk"] = { "<cmd> Telescope keymaps <CR>", "Show Keys" },

		["<leader>p"] = { "<cmd>Telescope projects<cr>", "Projects" },
		["<leader>t"] = { "<cmd>TroubleToggle<cr>", "Trouble" },
		["<leader>wf"] = { "<cmd>let g:neovide_fullscreen=!g:neovide_fullscreen<cr>", "Toggle Fullscreen" },

		["<leader>?"] = {
			function()
				require("telescope.builtin").oldfiles()
			end,
			"[?] Find recently opened files",
		},
		["<leader><space>"] = {
			function()
				-- Check if the alternate buffer exists and is valid
				local alt_bufnr = vim.fn.bufnr("#")
				if alt_bufnr ~= -1 and vim.api.nvim_buf_is_valid(alt_bufnr) then
					vim.cmd("buffer #")
				else
					vim.cmd("bprevious")
				end
			end,
			"[ ] Toggle between current and previous buffer",
		},
		["<leader>gf"] = {
			function()
				require("telescope.builtin").git_files()
			end,
			"Search [G]it [F]iles",
		},

		["<leader>c"] = { "+Coding" },

		-- Window navigation
		["<C-right>"] = { "<C-w>l", "Window Right" },
		["<C-left>"] = { "<C-w>h", "Window Left" },
		["<C-up>"] = { "<C-w>k", "Window Up" },
		["<C-down>"] = { "<C-w>j", "Window Down" },

		-- Formatting using Conform.nvim
		-- ["<leader>fm"] = { "<cmd>lua require('conform').format({ bufnr = args.buf })<cr>", "Format" },
		-- ["<leader>cu"] = { "<cmd>lua require('conform').update()<cr>", "Update" },

		-- Undo Tree
		["<leader>u"] = { "<cmd>UndotreeToggle<cr>", "Undo Tree" },

		-- Suda - write files with sudo using :W
		["<leader>W"] = { "<cmd>SudaWrite<cr>", "Write as sudo" },

		-- Git
		["<leader>gs"] = {
			function()
				require("neogit").open({ "commit" })
			end,
			"Open [G]it [C]ommit",
		},
		["<leader>gn"] = {
			function()
				local current_dir = vim.fn.getcwd()
				require("neogit").open({ cwd = current_dir })
			end,
			"Open Neogit in current directory",
		},
		["gr"] = {
			function()
				require("telescope.builtin").lsp_references()
			end,
			"[G]oto [R]eferences",
		},

		['y"'] = {
			function()
				local function copy_inside_quotes()
					local line = vim.fn.getline(".")
					local quotes = { '"', "'", "`" }

					for _, quote in ipairs(quotes) do
						local start, finish = line:find(quote .. ".-" .. quote)
						if start and finish then
							local content = line:sub(start + 1, finish - 1)
							vim.fn.setreg("+", content)
							print("Copied: " .. content)
							return
						end
					end

					print("No matching quotes found on this line")
				end
				copy_inside_quotes()
			end,
			"Copy inside quotes/backticks to clipboard (whole line)",
		},

		["]e"] = {
			function()
				vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
			end,
			"Go to next error",
		},
		["[e"] = {
			function()
				vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
			end,
			"Go to previous error",
		},

		-- Yanky

		-- Access yank history through telescope
		["<leader>fy"] = { "<cmd>Telescope yank_history<cr>", "Find Yank History" },

		-- Enhanced yank that preserves cursor position
		["y"] = { "<Plug>(YankyYank)", "Yanky Yank" },

		-- Cycle through yank ring with Alt+p/Alt+n (these don't conflict with your mappings)
		["<M-p>"] = { "<Plug>(YankyPreviousEntry)", "Yanky Previous Entry" },
		["<M-n>"] = { "<Plug>(YankyNextEntry)", "Yanky Next Entry" },

		-- Special put operations
		["[y"] = { "<Plug>(YankyPutIndentBeforeLinewise)", "Yanky Put Before (Indent)" },
		["]y"] = { "<Plug>(YankyPutIndentAfterLinewise)", "Yanky Put After (Indent)" },

		-- These will override your default p/P but provide enhanced functionality
		["p"] = { "<Plug>(YankyPutAfter)", "Yanky Put After" },
		["P"] = { "<Plug>(YankyPutBefore)", "Yanky Put Before" },

		-- These work with your existing gp/gP semantics but enhanced
		["gp"] = { "<Plug>(YankyGPutAfter)", "Yanky GPut After" },
		["gP"] = { "<Plug>(YankyGPutBefore)", "Yanky GPut Before" },

		-- Additional special put operations (filtering/indentation)
		[">y"] = { "<Plug>(YankyPutIndentAfterShiftRight)", "Yanky Put After (Shift Right)" },
		["<y"] = { "<Plug>(YankyPutIndentAfterShiftLeft)", "Yanky Put After (Shift Left)" },
		["=y"] = { "<Plug>(YankyPutAfterFilter)", "Yanky Put After (Filter)" },
	},
	x = {
		-- Visual mode mappings
		["y"] = { "<Plug>(YankyYank)", "Yanky Yank" },
		["p"] = { "<Plug>(YankyPutAfter)", "Yanky Put After" },
		["P"] = { "<Plug>(YankyPutBefore)", "Yanky Put Before" },
		["gp"] = { "<Plug>(YankyGPutAfter)", "Yanky GPut After" },
		["gP"] = { "<Plug>(YankyGPutBefore)", "Yanky GPut Before" },
	},

	-- Add text object for yanked text
	o = {
		["iy"] = {
			function()
				require("yanky.textobj").last_put()
			end,
			"Yanky Text Object",
		},
	},

	v = {
		["iy"] = {
			function()
				require("yanky.textobj").last_put()
			end,
			"Yanky Text Object",
		},
	},
}

M.lspconfig = {
	n = {
		["<leader>ca"] = {
			function()
				vim.lsp.buf.code_action()
			end,
			"Code Action",
		},

		["<leader>cd"] = {
			function()
				vim.diagnostic.open_float()
			end,
			"Floating Diagnostic",
		},

		["gh"] = {
			function()
				vim.diagnostic.open_float()
			end,
			"[G]oto [H]over",
		},

		["<leader>cr"] = {
			function()
				require("nvchad_ui.renamer").open()
			end,
			"Rename",
		},
	},
}

-- M.obsidian = {
-- 	n = {
-- 		["<leader>oc"] = {
-- 			function()
-- 				require("obsidian").util.toggle_checkbox()
-- 			end,
-- 			"[O]bsidian [C]heckbox",
-- 		},
-- 		["<leader>ot"] = {
-- 			function()
-- 				require("obsidian").util.toggle_task()
-- 			end,
-- 			"[O]bsidian [T]ask",
-- 		},
-- 		["<leader>oo"] = { "<cmd>ObsidianOpen<cr>", "[O]bsidian [O]pen" },
-- 		["<leader>on"] = { "<cmd>ObsidianNew<cr>", "[O]bsidian [N]ew" },
-- 		["<leader>os"] = { "<cmd>ObsidianSearch<cr>", "[O]bsidian [S]earch" },
-- 		["<leader>ob"] = { "<cmd>ObsidianBacklinks<cr>", "[O]bsidian [B]acklinks" },
-- 		["<leader>ol"] = { "<cmd>ObsidianLinks<cr>", "[O]bsidian [L]inks" },
-- 		["<leader>od"] = { "<cmd>ObsidianDaily<cr>", "[O]bsidian [D]aily" },
-- 		["<leader>op"] = { "<cmd>ObsidianPreview<cr>", "[O]bsidian [P]review" },
-- 	},
-- }

M.vtt = {
	plugin = true,

	n = {
		["<leader>ns"] = {
			function()
				require("custom.vtt").insert_new_subtitle()
			end,
			"Insert new subtitle",
		},
		["<leader>ts"] = {
			function()
				require("custom.vtt").increment_timestamp()
			end,
			"Increment timestamp by 1s",
		},
		["<leader>tx"] = {
			function()
				require("custom.vtt").decrement_timestamp()
			end,
			"Decrement timestamp by 1s",
		},
		["<leader>tms"] = {
			function()
				require("custom.vtt").increment_timestamp_ms()
			end,
			"Increment timestamp by 100ms",
		},
		["<leader>tmx"] = {
			function()
				require("custom.vtt").decrement_timestamp_ms()
			end,
			"Decrement timestamp by 100ms",
		},
		["<leader>sn"] = {
			function()
				require("custom.vtt").next_subtitle()
			end,
			"Next subtitle",
		},
		["<leader>sp"] = {
			function()
				require("custom.vtt").prev_subtitle()
			end,
			"Previous subtitle",
		},
		["<leader>tt"] = {
			function()
				require("custom.vtt").toggle_source_translated()
			end,
			"Toggle source/translated text",
		},
		["<leader>rf"] = {
			function()
				require("custom.vtt").reformat_timestamps()
			end,
			"Reformat timestamps",
		},
		["<leader>ti"] = {
			function()
				require("custom.vtt").increment_timings_from_cursor()
			end,
			"Increment timings from cursor",
		},
		["<leader>td"] = {
			function()
				require("custom.vtt").update_timestamp_duration()
			end,
			"Update timestamp duration",
		},
	},
}

-- Add this section to your M table in custom/mappings.lua

M.yanky = {
	plugin = true,

	n = {},
}

return M
