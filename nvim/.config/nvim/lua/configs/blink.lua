return {
  keymap = {
    preset = "none",
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "cancel", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
    ["<Tab>"] = {
      function(cmp)
        if cmp.is_visible and cmp.is_visible() then
          return cmp.select_next()
        end

        local ok, suggestion = pcall(require, "supermaven-nvim.completion_preview")
        if ok and suggestion.has_suggestion() then
          vim.schedule(function()
            suggestion.on_accept_suggestion()
          end)
          return true
        end

        if cmp.snippet_active() then
          return cmp.snippet_forward()
        end

        return false
      end,
      "fallback",
    },
    ["<S-Tab>"] = {
      function(cmp)
        if cmp.is_visible and cmp.is_visible() then
          return cmp.select_prev()
        end

        if cmp.snippet_active() then
          return cmp.snippet_backward()
        end

        return false
      end,
      "fallback",
    },
    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },

  completion = {
    keyword = {
      range = "full",
    },
    
    trigger = {
      prefetch_on_insert = true,
      show_on_keyword = true,
      show_on_trigger_character = true,
      show_on_insert_on_trigger_character = true,
    },
    
    list = {
      max_items = 200,
      selection = {
        preselect = true,
        auto_insert = true,
      },
    },
    
    accept = { 
      auto_brackets = { enabled = true },
      create_undo_point = true,
    },
    
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 100,
      window = {
        border = "rounded",
      },
    },
    
    ghost_text = {
      enabled = true,
    },
    
    menu = {
      border = "rounded",
      auto_show = true,
      max_height = 15,
      scrollbar = true,
      draw = {
        padding = { 0, 1 },
        gap = 1,
        columns = { 
          { "kind_icon" }, 
          { "label", "label_description", gap = 1 },
        },
        components = {
          kind_icon = {
            text = function(ctx) return ctx.kind_icon .. " " end,
            highlight = function(ctx)
              return ctx.kind_hl
            end,
          },
          label = {
            width = { fill = true, max = 60 },
            text = function(ctx) return ctx.label .. ctx.label_detail end,
            highlight = function(ctx)
              local highlights = {
                { 0, #ctx.label, group = ctx.deprecated and 'BlinkCmpLabelDeprecated' or 'BlinkCmpLabel' },
              }
              if ctx.label_detail then
                table.insert(highlights, { #ctx.label, #ctx.label + #ctx.label_detail, group = 'BlinkCmpLabelDetail' })
              end
              for _, idx in ipairs(ctx.label_matched_indices) do
                table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
              end
              return highlights
            end,
          },
          label_description = {
            width = { max = 30 },
            text = function(ctx) return ctx.label_description end,
            highlight = 'BlinkCmpLabelDescription',
          },
        },
      },
    },
  },
  
  fuzzy = {
    frecency = {
      enabled = true,
    },
    use_proximity = true,
    sorts = {
      "score",
      "sort_text",
    },
  },

  sources = {
    default = {
      "lsp",
      "path",
      "snippets",
      "buffer",
    },

    providers = {
      lsp = {
        name = "LSP",
        module = "blink.cmp.sources.lsp",
        min_keyword_length = 0,
        score_offset = 0,
      },

      path = {
        name = "Path",
        module = "blink.cmp.sources.path",
        score_offset = 3,
        opts = {
          trailing_slash = false,
          label_trailing_slash = true,
          get_cwd = function(context)
            return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
          end,
        },
      },

      snippets = {
        name = "Snippet",
        module = "blink.cmp.sources.snippets",
        score_offset = -3,
        opts = {
          search_paths = { runtime_dir = true },
        },
      },

      buffer = {
        name = "Buffer",
        module = "blink.cmp.sources.buffer",
        min_keyword_length = 3,
        score_offset = -3,
        opts = {
          get_bufnrs = function()
            return vim.tbl_filter(function(buf)
              return vim.bo[buf].buftype == ''
            end, vim.api.nvim_list_bufs())
          end,
        },
      },
    },
  },

  snippets = {
    preset = "luasnip",
  },
}
