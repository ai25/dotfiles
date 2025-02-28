
---@param bufnr integer
---@param ... string
---@return string
local function first(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

local options = {
	lsp_fallback = true,
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>fm",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    format_on_save = { timeout_ms = 500 },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,

  formatters_by_ft = {
    lua = { "stylua" },
    javascript = function(bufnr)
      -- First run either prettierd or prettier, then eslint_d or eslint
      return {
        first(bufnr, "prettierd", "prettier"),
        first(bufnr, "eslint_d", "eslint"),
      }
    end,
    typescript = function(bufnr)
      return {
        first(bufnr, "prettierd", "prettier"),
        first(bufnr, "eslint_d", "eslint"),
      }
    end,
    javascriptreact = function(bufnr)
      return {
        first(bufnr, "prettierd", "prettier"),
        first(bufnr, "eslint_d", "eslint"),
      }
    end,
    typescriptreact = function(bufnr)
      return {
        first(bufnr, "prettierd", "prettier"),
        first(bufnr, "eslint_d", "eslint"),
      }
    end,
    css = { "prettier" },
    html = { "prettier" },
    sh = { "shfmt" },
    php = { "phpcbf" },
    json = { "prettierd" },
    kotlin = { "ktlint" },
    -- Use the "*" filetype to run formatters on all filetypes
    -- ["*"] = { "codespell" },
    -- Use the "_" filetype to run formatters on filetypes that don't
    -- have other formatters configured
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
