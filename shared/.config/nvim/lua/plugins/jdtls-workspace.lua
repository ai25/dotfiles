return {
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = function(_, opts)
      local function installed_jdtls_version()
        local receipt_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls/mason-receipt.json"
        if vim.fn.filereadable(receipt_path) == 0 then
          return "unknown"
        end

        local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(receipt_path), "\n"))
        if not ok or type(decoded) ~= "table" then
          return "unknown"
        end

        local source = decoded.source
        local source_id = type(source) == "table" and source.id or nil
        local version = type(source_id) == "string" and source_id:match("@v?([^@]+)$") or nil
        return version or "unknown"
      end

      local jdtls_version = installed_jdtls_version()

      opts.project_name = function(root_dir)
        if not root_dir or root_dir == "" then
          return nil
        end

        local normalized = vim.fs.normalize(root_dir)
        local basename = vim.fs.basename(normalized):gsub("[^%w._-]", "_")
        local digest = vim.fn.sha256(normalized):sub(1, 12)
        return string.format("%s-%s", basename, digest)
      end

      opts.jdtls_config_dir = function(project_name)
        return string.format("%s/jdtls/%s/%s/config", vim.fn.stdpath("cache"), jdtls_version, project_name)
      end

      opts.jdtls_workspace_dir = function(project_name)
        return string.format("%s/jdtls/%s/%s/workspace", vim.fn.stdpath("cache"), jdtls_version, project_name)
      end
    end,
  },
}
