local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local utils = require("telescope-gitignore.utils")
local display = require("telescope-gitignore.display")
local extension_conf = require("telescope-gitignore.conf")

local M = {}

local Fetcher = {}

---@alias ContentHandler fun(content: string|nil)

--- Get content (Cache -> Web -> Save)
--- @param entry table # The telescope entry that represents the gitignore template
--- @param callback ContentHandler # What to do after saving in cache
function Fetcher.get_content(entry, callback)
  local cache_path = utils.get_cache_path(entry.name)
  local cached_content = utils.read_file(cache_path)

  if not cached_content and entry.url then
    utils.curl(entry.url, function(content)
      if content then
        utils.write_file(cache_path, content)
      end
      cached_content = content
    end)
  end

  callback(cached_content)
end

---@class GitignoreTemplate
---@field name string The name of the gitignore (e.g., "Python")
---@field url string|nil The download URL from GitHub API

---@alias PickerListCallback fun(templates: GitignoreTemplate[], title: string)

--- Load the list of templates (API -> Fallback Local)
--- @param callback PickerListCallback # Generate the telescope menu from the list of templates and the title
function Fetcher.load_list(callback)
  local config = extension_conf.get_config()

  utils.curl(config.github_api_url, function(json_raw)
    local templates = {}
    local title = nil
    local ok, data = pcall(vim.json.decode, json_raw or "")

    if ok and type(data) == "table" then
      -- Mode Online
      for _, file in ipairs(data) do
        if file.name:match("%.gitignore$") then
          table.insert(templates, {
            name = file.name:gsub("%.gitignore$", ""),
            url = file.download_url
          })
        end
      end
      title = config.prompt_title
    else
      -- Mode Offline (Fallback)
      vim.notify("Gitignore: Offline Mode", vim.log.levels.WARN)
      local files = vim.fn.glob(utils.get_cache_dir() .. "/*.gitignore", false, true)
      for _, file in ipairs(files) do
        table.insert(templates, {
          name = vim.fn.fnamemodify(file, ":t:r"),
          url = nil
        })
      end
      title = config.offline_prompt_title
    end

    assert(title ~= nil)
    callback(templates, title)
  end)
end

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
