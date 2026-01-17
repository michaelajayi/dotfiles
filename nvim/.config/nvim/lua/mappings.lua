require("nvchad.mappings")

local map = vim.keymap.set
local builtin = require("telescope.builtin")

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Keymap for finding ALL files, including hidden ones
map("n", "<space>fa", function()
	builtin.find_files({
		hidden = true,
		no_ignore = true,
	})
end, { desc = "Find ALL Files (including hidden) " })

vim.keymap.set("n", "<space>en", function()
	builtin.find_files({
		cwd = vim.fn.stdpath("config"),
	})
end)

vim.api.nvim_set_hl(0, "YankFlashBG", { bg = "#AEC6CF", bold = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank({ higroup = "YankFlashBG", timeout = 100 })
	end,
})

-- Oil.nvim keymap (default)
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- When a line wraps to multiple screen lines, j/k and arrows will move
-- through each visual line instead of jumping to the next logical line
map("n", "j", "gj", { desc = "Move down (visual line)", silent = true })
-- Normal mode: Arrow keys and j/k move by visual lines
map("n", "k", "gk", { desc = "Move up (visual line)", silent = true })
map("n", "<Down>", "gj", { desc = "Move down (visual line)", silent = true })
map("n", "<Up>", "gk", { desc = "Move up (visual line)", silent = true })

-- Visual mode: Same behavior when selecting text
map("v", "j", "gj", { desc = "Move down (visual line)", silent = true })
map("v", "k", "gk", { desc = "Move up (visual line)", silent = true })
map("v", "<Down>", "gj", { desc = "Move down (visual line)", silent = true })
map("v", "<Up>", "gk", { desc = "Move up (visual line)", silent = true })

-- Insert mode: Arrow keys move by visual lines
map("i", "<Down>", "<C-o>gj", { desc = "Move down (visual line)", silent = true })
map("i", "<Up>", "<C-o>gk", { desc = "Move up (visual line)", silent = true })

vim.g.border_style = "rounded" -- or "single", "double", "solid", "none"

vim.keymap.set("n", "<leader>fgw", function()
	-- Get the current word under the cursor at the moment the key is pressed
	local current_word = vim.fn.expand("<cword>")

	builtin.live_grep({
		default_text = current_word,
	})
end, { desc = "Live Grep (Word Under Cursor)" })

-- Sets the main 'Keyword' group to italic (covers most languages)
vim.api.nvim_set_hl(0, "Keyword", { italic = true })

-- Sets the Tree-sitter keyword group to italic (for modern syntax)
vim.api.nvim_set_hl(0, "@keyword", { italic = true })

vim.api.nvim_set_hl(0, "Conditional", { italic = true })
vim.api.nvim_set_hl(0, "Exception", { italic = true })
vim.api.nvim_set_hl(0, "@keyword.conditional", { italic = true })
vim.api.nvim_set_hl(0, "@keyword.exception", { italic = true })

-- This gurantees the highlight runs AFTER the colorscheme is loaded.
vim.api.nvim_create_autocmd("ColorScheme", {
	once = true,
	callback = function()
		-- Set the AlphaHeader Highlight group with your desired color.
		-- I'm using #A4C3FF, but you can change the hex code.
		vim.cmd([[ highlight AlphaHeader guifg = "#A4C3FF" ]])
	end,
})

vim.opt.termguicolors = true

-- map("n", "<Tab>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
-- map("n", "<S-Tab>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<BS>", "<C-^>", { desc = "Toggle to last buffer (alternate)" })
map("n", "<leader>x", "<Cmd>Bdelete<CR>", { desc = "Close buffer (keep window)" })
map("n", "<leader>X", "<Cmd>%bd|e#|bd#<CR>", { desc = "Close all buffers except current" })

-- Navigate between windows
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Telescope fuzzy finding
map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
map("n", "<leader>fo", builtin.oldfiles, { desc = "Find recent files" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
map("n", "<leader>fk", builtin.keymaps, { desc = "Find keymaps" })
map("n", "<leader>fc", builtin.commands, { desc = "Find commands" })
map("n", "<leader>fr", builtin.resume, { desc = "Resume last search" })

-- Search in current buffer (moved from <leader>/ to restore comment toggle)
map("n", "<leader>fs", builtin.current_buffer_fuzzy_find, { desc = "Search in current file" })

-- Copy diagnostic message under cursor to clipboard
map("n", "<leader>xy", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if #diagnostics > 0 then
		local message = diagnostics[1].message
		vim.fn.setreg("+", message) -- Copy to system clipboard

		-- Show shortened notification for long messages
		local preview = message:len() > 50 and (message:sub(1, 50) .. "...") or message
		vim.notify("Diagnostic copied:\n" .. preview, vim.log.levels.INFO)
	else
		vim.notify("No diagnostic on current line", vim.log.levels.WARN)
	end
end, { desc = "Copy diagnostic message to clipboard" })

-- Override :bd and :bw to use bbye's commands instead
-- Now typing :bd will keep your splits open!
vim.cmd([[
  cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdpos() == 3 ? 'Bd' : 'bd'
  cnoreabbrev <expr> bw getcmdtype() == ':' && getcmdpos() == 3 ? 'Bw' : 'bw'
]])

-- Visual mode: Better indenting (stays in visual mode)
map("v", "<", "<gv", { desc = "Indent left (stay in visual)" })
map("v", ">", ">gv", { desc = "Indent right (stay in visual)" })

-- Normal mode: Move lines up/down (auto-indents after moving)
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Visual mode: Move selected lines up/down (stays selected, format after with <leader>fm)
map("v", "<A-j>", ":m '>+1<CR>gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv", { desc = "Move selection up" })

map("n", "<leader>ap", "<cmd>FixAutopairs<CR>", { desc = "Fix/restart autopairs" })

-- Tell neovim that - is a keyword for example bg-red-600 for diw, ciw commands to work properly
vim.opt.iskeyword:append("-")

-- nvim-ufo keymaps
map("n", "<leader><leader>", "za", { desc = "Toggle fold" })

map("n", "<leader>zc", function()
	require("ufo").closeAllFolds()
end, { desc = "Close all folds" })
map("n", "<leader>zo", function()
	require("ufo").openAllFolds()
end, { desc = "Open all folds" })

map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
-- map("n", "gtd", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show hover documentation" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
-- map('n', 'gt', 'gg', { desc = 'Go to top of buffer' })
