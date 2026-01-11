require("oil").setup({
  -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
  default_file_explorer = true,

  -- Columns to display
  columns = {
    "icon",
    -- "permissions",
    -- "size",
    -- "mtime",
  },

  -- Buffer-local options to use for oil buffers
  buf_options = {
    buflisted = false,
    bufhidden = "hide",
  },

  -- Window-local options to use for oil buffers
  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    conceallevel = 3,
    concealcursor = "nvic",
  },

  -- Delete files to trash instead of permanently
  delete_to_trash = true,

  -- Skip confirmation for simple operations
  skip_confirm_for_simple_edits = true,

  -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
  prompt_save_on_select_new_entry = true,

  -- Keymaps in oil buffer
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open in vertical split" },
    ["<C-x>"] = { "actions.select", opts = { horizontal = true }, desc = "Open in horizontal split" },
    ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open in new tab" },
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-h>"] = false, -- Disable so window navigation works
    ["<C-j>"] = false, -- Disable so window navigation works
    ["<C-k>"] = false, -- Disable so window navigation works
    ["<C-l>"] = false, -- Disable so window navigation works
    ["-"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
    ["g\\"] = "actions.toggle_trash",
    ["<C-r>"] = "actions.refresh",
  },

  -- Set to false to disable all of the above keymaps
  use_default_keymaps = true,

  -- Constrain cursor to prevent navigation to problematic directories
  constrain_cursor = false,

  view_options = {
    -- Show files and directories that start with "."
    show_hidden = false,

    -- This function defines what is considered a "hidden" file
    is_hidden_file = function(name, bufnr)
      return vim.startswith(name, ".")
    end,

    -- This function defines what will never be shown, even when `show_hidden` is set
    is_always_hidden = function(name, bufnr)
      return false
    end,

    -- Sort file names in a more intuitive order for humans
    natural_order = true,

    sort = {
      -- sort order can be "asc" or "desc"
      { "type", "asc" },
      { "name", "asc" },
    },
  },

  -- Configuration for the floating window in oil.open_float
  float = {
    padding = 2,
    max_width = 90,
    max_height = 30,
    border = "rounded",
    win_options = {
      winblend = 0,
    },
    -- This is the config that will be passed to nvim_open_win.
    override = function(conf)
      return conf
    end,
  },

  -- Configuration for the actions floating preview window
  preview = {
    max_width = 0.9,
    min_width = { 40, 0.4 },
    width = nil,
    max_height = 0.9,
    min_height = { 5, 0.1 },
    height = nil,
    border = "rounded",
    win_options = {
      winblend = 0,
    },
    -- Set to true to automatically preview files when navigating
    -- Recommended: leave false and use C-p manually
    update_on_cursor_moved = false,
  },

  -- Configuration for the floating progress window
  progress = {
    max_width = 0.9,
    min_width = { 40, 0.4 },
    width = nil,
    max_height = { 10, 0.9 },
    min_height = { 5, 0.1 },
    height = nil,
    border = "rounded",
    minimized_border = "none",
    win_options = {
      winblend = 0,
    },
  },
})
