local options = {
  ensure_installed = {
    "bash",
    "fish",
    "lua",
    "luadoc",
    "markdown",
    "printf",
    "toml",
    "vim",
    "vimdoc",
    "yaml",
    "javascript",
    "typescript",
    "tsx",
    "html",
    "css",
    "json",
    "xml",        -- Maven pom.xml, Spring configs
    "properties", -- application.properties files
  },

  highlight = {
    enable = true,
    use_language_tree = true,
    -- Disable URL highlighting in strings to prevent underline wrapping issues
    disable = function(lang, buf)
      -- You can add specific conditions here if needed
      return false
    end,
    additional_vim_regex_highlighting = false,
  },

  indent = { enable = true },

  -- Treesitter text objects - understand code structure!
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj
      keymaps = {
        -- Functions
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        -- Classes
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        -- Parameters/arguments
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        -- Conditionals (if/else)
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        -- Loops
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        -- Comments
        ["a/"] = "@comment.outer",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- Add to jumplist
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
        ["]a"] = "@parameter.inner",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
        ["[a"] = "@parameter.inner",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
  },
}

require("nvim-treesitter.configs").setup(options)

-- Fix ampersand (&) highlighting in JSX/TSX strings
-- Treesitter treats & as HTML entity start, breaking URL query string highlighting
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescriptreact", "javascriptreact", "tsx", "jsx", "html" },
  callback = function()
    -- Force all string-related highlights to use consistent String color
    local string_hl = vim.api.nvim_get_hl(0, { name = "String" })

    -- Override ALL possible entity-related highlight groups
    local entity_groups = {
      "@string.special",
      "@character.special",
      "@string.special.url",
      "@character.special.html",
      "@constant.html",
      "@entity",
      "@text.uri",
      "@text.reference",
      "@markup.link",
      "@markup.raw",
      "htmlSpecialChar",
      "htmlEntity",
      "@constant.character.escape",
      "@string.escape",
      "@variable", -- KEY FIX: Treesitter treats &param as variable in strings
      "variable",  -- Non-treesitter variable group
    }

    for _, group in ipairs(entity_groups) do
      vim.api.nvim_set_hl(0, group, string_hl)
    end
  end,
})
