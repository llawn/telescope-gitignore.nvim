local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local utils = require("telescope-gitignore.utils")
local display = require("telescope-gitignore.display")
local extension_conf = require("telescope-gitignore.conf")

local Fetcher = require("telescope-gitignore.fetcher")
local M = {}


function M.open(opts)
  Fetcher.load_list(function(templates, title)
    if #templates == 0 then
      return vim.notify("No templates found.", vim.log.levels.ERROR)
    end

    pickers.new(opts or {}, {
      prompt_title = title,
      finder = finders.new_table({
        results = templates,
        entry_maker = function(entry)
          return {
            value = entry,
            ordinal = entry.name,
            name = entry.name,
            display = display.gen_make_display(),
          }
        end,
      }),
      sorter = conf.generic_sorter(opts),

      previewer = previewers.new_buffer_previewer({
        title = "Preview",
        define_preview = function(self, entry)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Loading..." })

          Fetcher.get_content(entry.value, function(content)
            if not vim.api.nvim_buf_is_valid(self.state.bufnr) then return end

            local lines = content and vim.split(content, "\n") or { "Unavailable" }
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            vim.api.nvim_set_option_value("filetype", "gitignore", { buf = self.state.bufnr })
          end)
        end,
      }),

      -- Select actions
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if selection then
            Fetcher.get_content(selection.value, function(content)
              if content then
                extension_conf.get_config().on_select(selection.value.name, content)
              else
                vim.notify("Empty content or error when loading", vim.log.levels.ERROR)
              end
            end)
          end
        end)
        return true
      end,
    }):find()
  end)
end

return M
