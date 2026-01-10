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
