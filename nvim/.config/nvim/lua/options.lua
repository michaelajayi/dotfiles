require("nvchad.options")

local o = vim.o
o.number = true
o.relativenumber = true

vim.opt.wildignore:append({ "*/node_modules/*", "*/.git/*", "*/dist/*", "*/build/*" })

vim.opt.undofile = true -- Enable persistent undo

-- Suppress swap file warnings (for session restore)
vim.opt.shortmess:append("A")
vim.opt.shortmess:append("I")
vim.opt.shortmess:append("W")
vim.opt.shortmess:append("c") -- Don't warn about existing swap files

o.updatetime = 1000 -- Reduced CursorHold frequency (was 300ms, now 1000ms)

-- Show tabufline always (NvChad's buffer/tab line)
o.showtabline = 2 -- Always show

-- Enable true color support (required for smear cursor)
o.termguicolors = true

-- Ensure cursor is visible and can be animated
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- vim.o.winbar = "%{%v:lua.vim.fn.expand('%:.')%}"

-- Disable terminal synchronization for better scroll performance on macOS
-- termsync uses terminal sync sequences to prevent tearing, but can cause lag
-- Recommended by Mitchell Hashimoto for smooth scrolling on Mac
o.termsync = false

-- Disable smooth scrolling for mouse input (instant scrolling, no lag)
o.mousescroll = "ver:1,hor:0" -- Scroll 1 line per mouse wheel tick

-- Auto-reload files when changed externally
o.autoread = true

-- PERFORMANCE FIX: Reduced frequency of file change checks (updatetime now 1000ms)
vim.api.nvim_create_autocmd({ "FocusGained", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

-- Notification when file changes
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	pattern = "*",
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
	end,
})

-- o.cursorline = true
-- o.cursorlineopt = "both"

o.wrap = true -- Enable line wrapping
o.linebreak = true -- Break lines at word boundaries (no more "nex" and "t-config" splits!)
o.breakindent = true -- Preserve indentation when wrapping
o.showbreak = "↪ " -- Visual indicator for wrapped lines

-- Disable concealment in strings (fixes grey circles appearing mid-string)
o.conceallevel = 0 -- 0 = show all text, 2 = hide concealed text (default)
o.concealcursor = "" -- Never conceal on cursor line

-- Disable LSP semantic tokens for more consistent syntax highlighting
-- This prevents LSP from overriding Treesitter highlighting
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			-- Keep semantic tokens but disable modifiers that can cause visual issues
			client.server_capabilities.semanticTokensProvider = nil
		end
	end,
})

-- Fix for links/URLs: Prevent underlines from extending to end of line
-- This is a known Vim issue where underlines on wrapped lines extend too far
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		-- Force cursor line number to white
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })
		-- vim.api.nvim_set_hl(0, "CursorLine", { bg = "#26233a" })

		-- Get base String highlight to ensure consistency
		local string_hl = vim.api.nvim_get_hl(0, { name = "String" })
		local url_color = string_hl.fg or "#7aa2f7"

		-- URL styling (italic instead of underline)
		vim.api.nvim_set_hl(0, "Underlined", { fg = url_color, italic = true })
		vim.api.nvim_set_hl(0, "@string.special.url", { fg = url_color, italic = true })
		vim.api.nvim_set_hl(0, "@markup.link.url", { fg = url_color, italic = true })

		-- Fix HTML entities (&amp;, &nbsp;, etc.) in strings to match string color
		-- This prevents & in URLs from being highlighted differently
		local entity_groups = {
			"@character.special",
			"@character.special.html",
			"@entity",
			"htmlSpecialChar",
			"htmlEntity",
			"@constant.character.escape",
			"@string.escape",
			"@variable", -- Treesitter parses &param as variable in strings
			"variable",
		}
		for _, group in ipairs(entity_groups) do
			vim.api.nvim_set_hl(0, group, string_hl)
		end
	end,
})

-- Force cursor line number to white
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#26233a" })

local string_hl = vim.api.nvim_get_hl(0, { name = "String" })
local url_color = string_hl.fg or "#7aa2f7"

vim.api.nvim_set_hl(0, "Underlined", { fg = url_color, italic = true })
vim.api.nvim_set_hl(0, "@string.special.url", { fg = url_color, italic = true })
vim.api.nvim_set_hl(0, "@markup.link.url", { fg = url_color, italic = true })

-- Apply entity fixes immediately
local entity_groups = {
	"@character.special",
	"@character.special.html",
	"@entity",
	"htmlSpecialChar",
	"htmlEntity",
	"@constant.character.escape",
	"@string.escape",
	"@variable",
	"variable",
}
for _, group in ipairs(entity_groups) do
	vim.api.nvim_set_hl(0, group, string_hl)
end

-- Diagnostic: Show highlight group under cursor
vim.api.nvim_create_user_command("ShowHighlight", function()
	local result = vim.treesitter.get_captures_at_cursor(0)
	if #result == 0 then
		print("No treesitter captures found")
		return
	end
	print("Highlight groups under cursor:")
	for _, capture in ipairs(result) do
		print("  - " .. capture)
	end
end, { desc = "Show Treesitter highlight groups under cursor" })

-- Emergency fix command for when filetype detection fails (works for ANY filetype)
vim.api.nvim_create_user_command("FixFiletype", function()
	local filename = vim.fn.expand("%:t")

	-- Force filetype detection
	vim.cmd("filetype detect")

	-- If still empty, try setting based on extension using Neovim's built-in detection
	if vim.bo.filetype == "" then
		local ext = vim.fn.expand("%:e")
		if ext ~= "" then
			-- Let Neovim figure it out from extension
			vim.bo.filetype = ext
		end
	end

	-- Restart LSP for this buffer
	vim.cmd("LspRestart")

	local ft = vim.bo.filetype ~= "" and vim.bo.filetype or "unknown"
	vim.notify("Filetype: " .. ft .. " | LSP restarted for " .. filename, vim.log.levels.INFO)
end, { desc = "Fix filetype detection and restart LSP" })

-- Hide cmdline when not in use (Neovim 0.8+)
o.cmdheight = 0

vim.opt.shortmess:append("I")
vim.opt.shortmess:append("W")
vim.opt.shortmess:append("c")

o.showmode = false

vim.diagnostic.config({
	virtual_text = false,
	signs = false,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
	},
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { sp = "#f38ba8", undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { sp = "#f9e2af", undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { sp = "#89b4fa", undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { sp = "#a6e3a1", undercurl = true })

-- Folding options (nvim-ufo + statuscol)
o.foldcolumn = "1" -- Show fold column for +/- signs
o.foldlevel = 99
o.foldlevelstart = 99
o.foldenable = true
o.fillchars = [[eob: ,fold: ,foldopen:-,foldsep:│,foldclose:+]]

-- Auto-open folds during incremental search (/ or ?)
-- This temporarily disables folds when searching so matches are visible as you type
vim.api.nvim_create_autocmd("CmdlineEnter", {
	pattern = { "/", "?" },
	callback = function()
		vim.o.foldenable = false
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	pattern = { "/", "?" },
	callback = function()
		vim.o.foldenable = true
	end,
})
