local M = {}

local function load_palette()
  local path = vim.fn.expand("~/.local/state/caelestia/scheme.json")
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()

  local ok, decoded = pcall(vim.json.decode, content)
  if not ok then
    return nil
  end
  return decoded.colours
end

function M.apply()
  local p = load_palette()
  if not p then
    return
  end

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.termguicolors = true
  vim.g.colors_name = "caelestia"

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  local function hex(x)
    return "#" .. x
  end

  -- Core UI
  hi("Normal", { fg = hex(p.text), bg = hex(p.base) })
  hi("NormalFloat", { fg = hex(p.text), bg = hex(p.surfaceContainer) })
  hi("CursorLine", { bg = hex(p.surface1) })
  hi("LineNr", { fg = hex(p.overlay1) })
  hi("CursorLineNr", { fg = hex(p.primary) })

  -- A few basics so it looks sane immediately
  hi("Comment", { fg = hex(p.subtext0), italic = true })
  hi("String", { fg = hex(p.green) })
  hi("Function", { fg = hex(p.primary) })
  hi("Keyword", { fg = hex(p.mauve) })
  hi("Type", { fg = hex(p.tertiary) })
  hi("ErrorMsg", { fg = hex(p.onError), bg = hex(p.errorContainer) })

  -- Diagnostics
  hi("DiagnosticError", { fg = hex(p.error) })
  hi("DiagnosticWarn", { fg = hex(p.peach) })
  hi("DiagnosticInfo", { fg = hex(p.primary) })
  hi("DiagnosticHint", { fg = hex(p.teal) })
end

return M
