return {
	{
		"hrsh7th/nvim-cmp",
		enabled = false,
	},

	{
		"nvim-tree/nvim-tree.lua",
		enabled = false,
	},

	{
		"supermaven-inc/supermaven-nvim",
		event = "InsertEnter",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<C-l>",
					clear_suggestion = "<C-]>",
					accept_word = "<C-j>",
				},
				ignore_filetypes = {
					yaml = true,
					markdown = true,
					help = true,
					gitcommit = true,
					gitrebase = true,
				},
				color = {
					suggestion_color = "#9aa0a6",
					cterm = 244,
				},
				log_level = "error",
				disable_inline_completion = false,
				disable_keymaps = false,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("configs.treesitter")
		end,
	},
	{
		"williamboman/mason.nvim",
		dependencies = {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		opts = {
			ensure_installed = {
				"lua-language-server",
				"html-lsp",
				"css-lsp",
				"typescript-language-server",
				"eslint_d", -- Fast ESLint for React/Next.js
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua",
					"prettier",
				},
				run_on_start = true,
				auto_update = true,
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = {
			ensure_installed = {
				"lua_ls",
				"cssls",
				"html",
				"jsonls",
				"ts_ls",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("nvchad.configs.lspconfig").defaults()
			require("configs.lspconfig")
			vim.diagnostic.config({
				virtual_text = false,
				signs = false,
				underline = true,
			})
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("configs.lint")
		end,
	},
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			require("configs.dap")
		end,
	},
	{
		"stevearc/conform.nvim",
		event = "BufWritePre", -- uncomment for format on save
		opts = require("configs.conform"),
	},
	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000,
		config = function()
			require("tiny-inline-diagnostic").setup({
				signs = {
					left = "",
					right = "",
					diag = "",
					arrow = "",
					up_arrow = "",
					vertical = "",
					vertical_end = "",
				},
			})
		end,
	},
	{
		"moll/vim-bbye",
		cmd = { "Bdelete", "Bwipeout" },
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "Oil" }, -- PERFORMANCE FIX: Only load when :Oil command is used
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		},
		config = function()
			require("configs.oil")
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},
	-- {
	--   "f-person/git-blame.nvim",
	--   event = "VeryLazy",
	--   opts = {
	--     enabled = false, -- Disabled: causes lag on cursor movement (j/k scrolling)
	--     message_template = " <summary> • <date> • <author> • <<sha>>",
	--     date_format = "%m-%d-%Y %H:%M:%S",
	--     virtual_text_column = 1,
	--   },
	-- },
	-- {
	--   "folke/trouble.nvim",
	--   opts = {},
	--   cmd = "Trouble",
	--   keys = {
	--     {
	--       "<leader>xx",
	--       "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	--       desc = "Buffer Diagnostics (Trouble)",
	--     },
	--     {
	--       "<leader>xX",
	--       "<cmd>Trouble diagnostics toggle<cr>",
	--       desc = "Diagnostics (Trouble)",
	--     },
	--     {
	--       "<leader>cs",
	--       "<cmd>Trouble symbols toggle focus=false<cr>",
	--       desc = "Symbols (Trouble)",
	--     },
	--     {
	--       "<leader>cl",
	--       "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	--       desc = "LSP Definitions / references / ... (Trouble)",
	--     },
	--     {
	--       "<leader>xL",
	--       "<cmd>Trouble loclist toggle<cr>",
	--       desc = "Location List (Trouble)",
	--     },
	--     {
	--       "<leader>xQ",
	--       "<cmd>Trouble qflist toggle<cr>",
	--       desc = "Quickfix List (Trouble)",
	--     },
	--   },
	-- },
	{
		url = "https://codeberg.org/andyg/leap.nvim",
		event = "VeryLazy",
		config = function()
			local leap = require("leap")

			-- Highlight unlabeled phase - shows all matches more clearly
			leap.opts.highlight_unlabeled_phase_one_targets = true

			-- Case sensitivity: smart case (case-insensitive unless you type uppercase)
			leap.opts.case_sensitive = false

			-- Equivalence classes - treat similar characters as same (less thinking)
			leap.opts.equivalence_classes = { " \t\r\n" } -- All whitespace treated as equivalent

			-- Max phase one targets - if only 1-2 matches, jump immediately
			leap.opts.max_phase_one_targets = nil -- nil = auto-select on single match

			-- KEYMAPS
			-- 's' for bidirectional search (searches both forward and backward)
			vim.keymap.set({ "n", "x", "o" }, "s", function()
				leap.leap({ target_windows = { vim.fn.win_getid() } })
			end, { desc = "Leap bidirectional" })

			-- 'gs' for cross-window leap (search across all visible windows)
			vim.keymap.set({ "n", "x", "o" }, "gs", function()
				leap.leap({
					target_windows = vim.tbl_filter(function(win)
						return vim.api.nvim_win_get_config(win).focusable
					end, vim.api.nvim_tabpage_list_wins(0)),
				})
			end, { desc = "Leap across windows" })

			-- 'gS' for cross-buffer leap (search in all open buffers)
			vim.keymap.set({ "n", "x", "o" }, "gS", function()
				leap.leap({
					target_windows = vim.tbl_filter(function(win)
						return vim.api.nvim_win_get_config(win).focusable
					end, vim.api.nvim_list_wins()),
				})
			end, { desc = "Leap across buffers" })
		end,
	},
	{
		"sphamba/smear-cursor.nvim",
		event = "VeryLazy",
		config = function()
			require("smear_cursor").setup({
				cursor_color = "#d9e0ee",
				smear_between_buffers = true,
				smear_between_neighbor_lines = false,
				scroll_buffer_space = false,
				legacy_computing_symbols_support = false,
				smear_insert_mode = false,
				distance_stop_animating = 0.5,
				stiffness = 0.4,
				trailing_stiffness = 0.3,
			})
		end,
	},
	{
		"echasnovski/mini.animate",
		event = "VeryLazy",
		config = function()
			local animate = require("mini.animate")
			animate.setup({
				scroll = {
					enable = false, -- Disabled: instant scrolling, no animations
					-- Fast timing for minimal lag
					timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
					subscroll = animate.gen_subscroll.equal({ max_output_steps = 120 }),
				},
				-- Disable other animations (you have smear-cursor already)
				cursor = { enable = false },
				resize = { enable = false },
				open = { enable = false },
				close = { enable = false },
			})
		end,
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- Load before reading files
		opts = {
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
		},
		init = function()
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
		end,
		keys = {
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
		},
	},
	{
		"saghen/blink.cmp",
		lazy = false,
		dependencies = {
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		version = "*",
		build = "nix run .#buildScripts.p1",
		opts = require("configs.blink"),
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local autopairs = require("nvim-autopairs")
			autopairs.setup({
				check_ts = true,
				ts_config = {
					lua = { "string" },
					javascript = { "template_string" },
					java = false,
				},
				fast_wrap = {
					map = "<M-e>",
					chars = { "{", "[", "(", '"', "'" },
					pattern = [=[[%'%"%>%]%)%}%,]]=],
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "Search",
					highlight_grey = "Comment",
				},
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = true,
				},
			})
		end,
	},
	{
		"andymass/vim-matchup",
		event = { "BufReadPost" },
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_treesitter_stopline = 500
		end,
	},
	{
		"olrtg/nvim-emmet",
		config = function()
			vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
		end,
	},
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			local notify = require("notify")
			notify.setup({
				background_colour = "#000000",
				fps = 60,
				icons = {
					DEBUG = "",
					ERROR = "",
					INFO = "",
					TRACE = "✎",
					WARN = "",
				},
				level = 4,
				minimum_width = 50,
				render = "compact", -- Try: "default", "minimal", "simple", "compact"
				stages = "fade_in_slide_out", -- Try: "fade", "slide", "static"
				timeout = 2000,
				top_down = true, -- true = top right, false = bottom right
			})
			vim.notify = notify
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()
			-- Snippet settings
			luasnip.config.set_config({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				enable_autosnippets = true,
			})
		end,
	},
	{
		"hat0uma/csvview.nvim",
		---@module "csvview"
		---@type CsvView.Options
		opts = {
			parser = { comments = { "#", "//" } },
			keymaps = {
				-- Text objects for selecting fields
				textobject_field_inner = { "if", mode = { "o", "x" } },
				textobject_field_outer = { "af", mode = { "o", "x" } },
				jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
				jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
				jump_next_row = { "<Enter>", mode = { "n", "v" } },
				jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
			},
		},
		cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	},
	{
		"luukvbaal/statuscol.nvim",
		event = "BufReadPost",
		config = function()
			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
				segments = {
					{ text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" }, -- folds + spacing
					{ text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" }, -- line numbers
					{ text = { "%s" }, click = "v:lua.ScSa" }, -- signs
					{ text = { " " } }, -- spacing before code
				},
			})
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		event = "BufReadPost",
		config = function()
			require("configs.ufo")
		end,
	},
}
