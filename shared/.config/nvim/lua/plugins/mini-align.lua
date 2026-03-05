return {
  {
    "nvim-mini/mini.align",
    version = false,
    config = function()
      local align = require("mini.align")

      local split_first_ws = align.new_step("split_first_ws", function(strings, _)
        local parts = {}

        for i, s in ipairs(strings) do
          if s == "" then
            parts[i] = { s }
          else
            local indent = s:match("^%s*") or ""
            local rest = s:sub(#indent + 1)

            local a, b = rest:find("%s+")
            if a then
              local left = indent .. rest:sub(1, a - 1)
              local right = rest:sub(b + 1)
              parts[i] = { left, " ", right }
            else
              parts[i] = { s }
            end
          end
        end

        return align.as_parts(parts)
      end)

      local split_last_ws = align.new_step("split_last_ws", function(strings, _)
        local parts = {}

        for i, s in ipairs(strings) do
          if s == "" then
            parts[i] = { s }
          else
            local indent = s:match("^%s*") or ""
            local rest = s:sub(#indent + 1)

            local last_a, last_b
            local from = 1
            while true do
              local a, b = rest:find("%s+", from)
              if not a then
                break
              end
              last_a, last_b = a, b
              from = b + 1
            end

            if last_a then
              local left = indent .. rest:sub(1, last_a - 1)
              local right = rest:sub(last_b + 1)
              parts[i] = { left, " ", right }
            else
              parts[i] = { s }
            end
          end
        end

        return align.as_parts(parts)
      end)

      align.setup({
        modifiers = {
          ["W"] = function(steps, _)
            steps.split = split_first_ws
          end,
          ["L"] = function(steps, _)
            steps.split = split_last_ws
          end,
        },
      })
    end,
  },
}
