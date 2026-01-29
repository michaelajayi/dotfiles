-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@class ChadrcConfig
local M = {}

M.base46 = {
  theme = "rosepine",
  transparency = true,

  hl_override = {
    BufferLineFill = { bg = "none" }, -- Remove background from bufferline
  },
}

M.nvdash = { load_on_startup = false }

M.ui = {
  statusline = {
    enabled = true,
    theme = "default",
    separator_style = "block", -- Flat blocks instead of angled arrows
  },
  tabufline = {
    enabled = true,
    order = { "treeOffset", "buffers", "tabs" }, -- Buffers left, tabs right
  }
}

M.lsp = M.lsp or {}
M.lsp.override = function(config)
  -- This function runs for every LSP that lspconfig tries to start.
  -- We only want to modify the configuration for ts_ls.
  if config.name == "ts_ls" then
    local lspconfig_util = require("lspconfig.util")

    config.root_dir = function(fname)
      local default_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" }
      local root = lspconfig_util.root_pattern(unpack(default_markers))(fname)

      if root then
        return root
      end

      return lspconfig_util.path.dirname(fname)
    end
  end
end


return M