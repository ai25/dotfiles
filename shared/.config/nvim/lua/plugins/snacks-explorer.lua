return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.explorer = opts.picker.sources.explorer or {}
      opts.picker.sources.explorer.win = opts.picker.sources.explorer.win or {}
      opts.picker.sources.explorer.win.list = opts.picker.sources.explorer.win.list or {}
      opts.picker.sources.explorer.win.list.keys = opts.picker.sources.explorer.win.list.keys or {}

      -- Let `/` use normal Vim buffer search in the explorer list instead of
      -- jumping into the Snacks picker input.
      opts.picker.sources.explorer.win.list.keys["/"] = false
      opts.picker.sources.explorer.win.list.keys["f"] = "toggle_focus"
    end,
  },
}
