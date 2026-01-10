---@module 'avante'
---@type avante.Config
require("avante").setup({
	disabled_tools = {
		"list_files", -- Built-in file operations
		"search_files",
		"read_file",
		"create_file",
		"rename_file",
		"delete_file",
		"create_dir",
		"rename_dir",
		"delete_dir",
		"bash", -- Built-in terminal access
		"web_search",
	},

	-- system_prompt as function ensures LLM always has latest MCP server state
	-- This is evaluated for every message, even in existing chats
	-- system_prompt = function()
	-- 	local hub = require("mcphub").get_hub_instance()
	-- 	return hub and hub:get_active_servers_prompt() or ""
	-- end,
	-- Using function prevents requiring mcphub before it's loaded
	-- custom_tools = function()
	-- 	return {
	-- 		require("mcphub.extensions.avante").mcp_tool(),
	-- 	}
	-- end,
	override_prompt_dir = vim.fn.expand("~/.config/avante/rules"),
	provider = "ollama",
	providers = {
		openai = {
			endpoint = "https://api.openai.com/v1",
			model = "gpt-4o",
			timeout = 30000, -- Timeout in milliseconds
			extra_request_body = {
				temperature = 0.75,
				max_tokens = 16384,
			},
		},
		ollama = {
			-- endpoint = "http://127.0.0.1:11434",
			endpoint = "http://localhost:8080",
			-- model = "gemma3n:e4b",
			-- model = "gemma3n:e2b",
			model = "qwen3:0.6b",
			timeout = 30000, -- Timeout in milliseconds
		},
		openrouter = {
			__inherited_from = "openai",
			endpoint = "https://openrouter.ai/api/v1",
			model = "deepseek/deepseek-chat-v3-0324:free",
		},
	},
})
