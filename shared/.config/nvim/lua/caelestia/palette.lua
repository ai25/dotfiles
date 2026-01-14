local M = {}

local json_path = vim.fn.expand("~/.local/state/caelestia/scheme.json")

local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

function M.load()
  local content = read_file(json_path)
  if not content then
    return nil
  end

  local ok, decoded = pcall(vim.json.decode, content)
  if not ok then
    return nil
  end

  return decoded.colours
end

return M
