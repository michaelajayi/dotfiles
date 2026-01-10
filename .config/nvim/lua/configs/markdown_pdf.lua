-- Markdown to PDF export functionality
local M = {}

-- Get the directory of the current file
local function get_file_dir()
  local file = vim.api.nvim_buf_get_name(0)
  return vim.fn.fnamemodify(file, ':p:h')
end

-- Get the current file name without extension
local function get_file_name()
  local file = vim.api.nvim_buf_get_name(0)
  return vim.fn.fnamemodify(file, ':t:r')
end

-- Export markdown to PDF with Mermaid diagram support
function M.export_to_pdf()
  -- Check if current buffer is markdown
  if vim.bo.filetype ~= 'markdown' then
    vim.notify('Not a markdown file!', vim.log.levels.ERROR)
    return
  end

  -- Get current file info
  local current_file = vim.api.nvim_buf_get_name(0)
  local file_dir = get_file_dir()
  local file_name = get_file_name()
  local output_pdf = file_dir .. '/' .. file_name .. '.pdf'

  -- Save the current buffer first
  vim.cmd('write')

  -- Show progress notification
  vim.notify('Exporting to PDF (rendering Mermaid diagrams)...', vim.log.levels.INFO)

  -- Run pandoc command with mermaid filter and weasyprint
  -- The mermaid-filter will convert mermaid code blocks to images
  local cmd = string.format(
    'pandoc "%s" -o "%s" --filter mermaid-filter --pdf-engine=weasyprint -V margin-top=20 -V margin-bottom=20 -V margin-left=20 -V margin-right=20 -V papersize=a4',
    current_file,
    output_pdf
  )

  -- Execute the command
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify('PDF exported successfully to:\n' .. output_pdf, vim.log.levels.INFO)

        -- Ask if user wants to open the PDF
        vim.defer_fn(function()
          local choice = vim.fn.confirm('Open PDF?', '&Yes\n&No', 1)
          if choice == 1 then
            vim.fn.jobstart({'open', output_pdf}, {detach = true})
          end
        end, 500)
      else
        vim.notify('PDF export failed! Check if mermaid-filter is installed (npm install -g mermaid-filter)', vim.log.levels.ERROR)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line ~= '' and not line:match('^WARNING:') then
            print('Error: ' .. line)
          end
        end
      end
    end
  })
end

-- Alternative: Export using browser rendering (best quality, handles all CSS)
function M.export_to_pdf_chrome()
  if vim.bo.filetype ~= 'markdown' then
    vim.notify('Not a markdown file!', vim.log.levels.ERROR)
    return
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  local file_dir = get_file_dir()
  local file_name = get_file_name()
  local temp_html = file_dir .. '/' .. file_name .. '_temp.html'
  local output_pdf = file_dir .. '/' .. file_name .. '.pdf'

  vim.cmd('write')
  vim.notify('Exporting to PDF (Chrome engine, best quality)...', vim.log.levels.INFO)

  -- First, convert markdown to standalone HTML with Mermaid support
  local html_cmd = string.format(
    'pandoc "%s" -o "%s" --standalone --filter mermaid-filter --metadata title="%s" --css=https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.5.1/github-markdown.min.css --css=https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.css',
    current_file,
    temp_html,
    file_name
  )

  vim.fn.jobstart(html_cmd, {
    on_exit = function(_, exit_code_html)
      if exit_code_html == 0 then
        -- Now convert HTML to PDF using Chrome headless
        local pdf_cmd = string.format(
          '/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome --headless --disable-gpu --print-to-pdf="%s" --no-pdf-header-footer "%s"',
          output_pdf,
          temp_html
        )

        vim.fn.jobstart(pdf_cmd, {
          on_exit = function(_, exit_code_pdf)
            -- Clean up temp HTML
            vim.fn.delete(temp_html)

            if exit_code_pdf == 0 then
              vim.notify('PDF exported successfully to:\n' .. output_pdf, vim.log.levels.INFO)
              vim.defer_fn(function()
                local choice = vim.fn.confirm('Open PDF?', '&Yes\n&No', 1)
                if choice == 1 then
                  vim.fn.jobstart({'open', output_pdf}, {detach = true})
                end
              end, 500)
            else
              vim.notify('Chrome PDF conversion failed! Make sure Chrome is installed.', vim.log.levels.ERROR)
            end
          end
        })
      else
        vim.notify('HTML conversion failed!', vim.log.levels.ERROR)
      end
    end
  })
end

-- LaTeX-based export (no Mermaid support, but good for text-heavy docs)
function M.export_to_pdf_latex()
  if vim.bo.filetype ~= 'markdown' then
    vim.notify('Not a markdown file!', vim.log.levels.ERROR)
    return
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  local file_dir = get_file_dir()
  local file_name = get_file_name()
  local output_pdf = file_dir .. '/' .. file_name .. '.pdf'

  vim.cmd('write')
  vim.notify('Exporting to PDF (LaTeX engine)...', vim.log.levels.INFO)

  local cmd = string.format(
    'pandoc "%s" -o "%s" --pdf-engine=xelatex -V geometry:margin=1in',
    current_file,
    output_pdf
  )

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify('PDF exported successfully to:\n' .. output_pdf, vim.log.levels.INFO)
        vim.defer_fn(function()
          local choice = vim.fn.confirm('Open PDF?', '&Yes\n&No', 1)
          if choice == 1 then
            vim.fn.jobstart({'open', output_pdf}, {detach = true})
          end
        end, 500)
      else
        vim.notify('PDF export failed! LaTeX may not be installed. Try the weasyprint method instead.', vim.log.levels.ERROR)
      end
    end
  })
end

-- Quick export to current directory
function M.quick_export()
  M.export_to_pdf()
end

return M
