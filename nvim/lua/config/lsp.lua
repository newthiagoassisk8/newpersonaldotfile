local M = {}

M.server_settings = {
  vtsls = {},
  vue_ls = {},
  eslint = {},
  tailwindcss = {},
  lua_ls = {
    settings = {
      Lua = {
        completion = { callSnippet = "Replace" },
      },
    },
  },
}

M.lsp_ensure_installed = { "vtsls", "vue_ls", "eslint", "tailwindcss", "lua_ls" }

M.tool_ensure_installed = {
  "typescript-language-server",
  "eslint-lsp",
  "tailwindcss-language-server",
  "lua-language-server",
}

function M.extend_servers(servers)
  return vim.tbl_deep_extend("force", servers or {}, M.server_settings)
end

function M.get_lsp_ensure_installed()
  return vim.deepcopy(M.lsp_ensure_installed)
end

function M.get_tool_ensure_installed(extra)
  local list = vim.deepcopy(M.tool_ensure_installed)
  for _, tool in ipairs(extra or {}) do
    if not vim.tbl_contains(list, tool) then
      table.insert(list, tool)
    end
  end
  return list
end

return M
