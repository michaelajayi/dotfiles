local M = {}

M.opts = {
	dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"), -- Session directory
	options = { "buffers", "curdir", "tabpages", "winsize" }, -- What to save
	pre_save = function()
		-- Close excluded buffer types before saving
		local excluded_filetypes = {
			"oil",
			"dap-repl",
			"dapui_console",
			"dapui_watches",
			"dapui_stacks",
			"dapui_breakpoints",
			"dapui_scopes",
			"notify",
			"trouble",
			"Trouble",
			"neo-tree",
			"NvimTree",
			"terminal",
		}

		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(buf) then
				local ft = vim.bo[buf].filetype
				if vim.tbl_contains(excluded_filetypes, ft) then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end
		end
	end,
}

M.init = function()
	-- Auto-restore session with delay for Treesitter compatibility
	-- Manual restore works fine, but auto-restore needs to wait for Treesitter
	vim.api.nvim_create_autocmd("VimEnter", {
		nested = true,
		callback = function()
			if vim.fn.argc() == 0 and vim.bo.filetype ~= "gitcommit" and vim.bo.filetype ~= "gitrebase" then
				-- Delay ensures Treesitter is fully loaded before session restore
				vim.defer_fn(function()
					require("persistence").load()

					-- Extra safety: Re-enable Treesitter on all buffers after restore
					vim.defer_fn(function()
						for _, buf in ipairs(vim.api.nvim_list_bufs()) do
							if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
								pcall(vim.cmd, "TSBufEnable highlight")
							end
						end
					end, 50) -- Small additional delay after restore
				end, 150) -- 150ms initial delay
			end
		end,
	})
end

M.keys = {
	{
		"<leader>qs",
		function()
			require("persistence").load()
		end,
		desc = "Restore Session",
	},
	{
		"<leader>ql",
		function()
			require("persistence").load({ last = true })
		end,
		desc = "Restore Last Session",
	},
	{
		"<leader>qd",
		function()
			require("persistence").stop()
		end,
		desc = "Don't Save Current Session",
	},
}

return M
