require "nvchad.autocmds"

-- Minimal autocmd to ensure Treesitter highlighting is applied
-- This runs ONCE per buffer when file is loaded (not on every cursor move)
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = "*",
  callback = function()
    -- Only apply if Treesitter is loaded and filetype is detected
    if vim.bo.filetype ~= "" then
      vim.schedule(function()
        -- Force Treesitter to attach to buffer
        local ts_available, _ = pcall(require, "nvim-treesitter")
        if ts_available then
          vim.cmd "silent! TSBufEnable highlight"
        end
      end)
    end
  end,
})

local function set_base_comment_italics()
  local hl = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  hl.italic = true
  vim.api.nvim_set_hl(0, "Comment", hl)
end

set_base_comment_italics()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_base_comment_italics,
})

local function set_supermaven_inline(enabled)
  local ok, preview = pcall(require, "supermaven-nvim.completion_preview")
  if not ok then
    return
  end

  preview.disable_inline_completion = not enabled
  if not enabled then
    preview.on_dispose_inlay()
  end
end

local supermaven_group = vim.api.nvim_create_augroup("SupermavenInlineToggle", { clear = true })

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuOpen",
  group = supermaven_group,
  callback = function()
    set_supermaven_inline(false)
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = { "BlinkCmpMenuClose", "BlinkCmpHide" },
  group = supermaven_group,
  callback = function()
    set_supermaven_inline(true)
  end,
})
