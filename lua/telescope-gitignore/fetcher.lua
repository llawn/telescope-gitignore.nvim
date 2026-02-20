local utils = require("telescope-gitignore.utils")
local conf = require("telescope-gitignore.conf")

local M = {}

---@alias ContentHandler fun(content: string|nil)

--- Get content (Cache, Fallback: Web + Save)
--- @param entry table The telescope entry that represents the gitignore template
--- @param callback ContentHandler: What to do after saving in cache
function M.get_content(entry, callback)
  local cache_path = utils.get_cache_path(entry.name)
  local saved_content = utils.read_file(cache_path)

  if not saved_content and entry.url then
    utils.curl(entry.url, function(content)
      if content then
        utils.write_file(cache_path, content)
      end
      saved_content = content
    end)
  end

  callback(saved_content)
end

---@class GitignoreTemplate
---@field name string The name of the gitignore (e.g., "Python")
---@field url string|nil The download URL from GitHub API

---@alias PickerListCallback fun(templates: GitignoreTemplate[], title: string)

--- Get the list of gitignore templates (Online, Fallback: Local)
--- @param callback PickerListCallback Generate the telescope menu from the list of templates and the title
function M.load_list(callback)
  local config = conf.get_config()

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
            url = file.download_url,
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
          url = nil,
        })
      end
      title = config.offline_prompt_title
    end

    assert(title ~= nil)
    callback(templates, title)
  end)
end

return M
