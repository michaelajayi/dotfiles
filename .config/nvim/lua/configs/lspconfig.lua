-- Using vim.lsp.config (new API for Neovim 0.11+)
-- See :help lspconfig-nvim-0.11

-- Helper function to find root directory
local function root_pattern(...)
  local patterns = {...}
  return function(path)
    local util = vim.fs or require("lspconfig.util")
    if vim.fs then
      return util.root(path, patterns)
    else
      return util.root_pattern(unpack(patterns))(path)
    end
  end
end

-- IMPORTANT: Configure TypeScript LSP first with proper filetypes
-- This ensures ts_ls attaches before tailwindcss on .ts files
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx"
  },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "none", -- Disable to prevent visual clutter
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "none",
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
      },
    },
  },
})

-- Configure tailwindcss with explicit filetypes (excluding plain .ts files)
-- This prevents tailwindcss from attaching to TypeScript files that aren't React/JSX
vim.lsp.config('tailwindcss', {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = {
    "html",
    "css",
    "scss",
    "sass",
    "postcss",
    "javascriptreact",
    "javascript.jsx",
    "typescriptreact",
    "typescript.tsx",
    -- Note: Deliberately excluding "typescript" and "javascript"
    -- Tailwind should only attach to JSX/TSX files, not plain TS/JS
  },
  root_markers = {
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.cjs",
    "postcss.config.mjs",
    "postcss.config.ts"
  },
  settings = {
    tailwindCSS = {
      -- Keep color decorators for Tailwind classes (useful feature!)
      -- The circles in URLs are from something else
      colorDecorators = true,
      lint = {
        -- Disable suggestions to convert arbitrary values to scale values
        -- Next.js templates use arbitrary values intentionally for clarity
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "error",
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning",
      },
      validate = true,
    },
  },
})

-- Configure lua_ls with proper root detection and Neovim settings
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
  single_file_support = false, -- Only activate in projects with a detected root
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }, -- Recognize 'vim' global for Neovim configs
      },
      workspace = {
        checkThirdParty = false, -- Disable third-party library prompts
        library = {
          vim.env.VIMRUNTIME, -- Add Neovim runtime files
        },
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- Setup other LSP servers
vim.lsp.config('html', {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  single_file_support = true,
})

vim.lsp.config('cssls', {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  single_file_support = true,
})

vim.lsp.config('jsonls', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  single_file_support = true,
})

-- Enable LSP servers for configured filetypes
vim.lsp.enable({ 'ts_ls', 'tailwindcss', 'lua_ls', 'html', 'cssls', 'jsonls' }) 
