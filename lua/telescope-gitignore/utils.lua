local job = require("plenary.job")
local M = {}

--- Get the cache directory for saving gitignore templates
--- @return string
function M.get_cache_dir()
  return require("telescope-gitignore.conf").get_config().cache_dir
end

--- Get the file path of a specific gitignore templates
--- @param name string # The name of the template
--- @return string # The file path of the template
function M.get_cache_path(name)
  return string.format("%s/%s.gitignore", M.get_cache_dir(), name)
end

--- Get the gitignore template content based of the cached file
--- @param path string # The gitignore template file to read
--- @return string|nil # If it fails to read the file return nothing, else return its content
function M.read_file(path)
  if vim.fn.filereadable(path) == 0 then return nil end
  return table.concat(vim.fn.readfile(path), "\n")
end

--- Write the content of the gitignore template in its cached file
--- @param path string # The cached file path
--- @param content string # The content to write
function M.write_file(path, content)
  local f = io.open(path, "w")
  if f then
    f:write(content)
    f:close()
  end
end

--- Fetching gitignore template with curl
--- @param url string # The url to fetch the gitignore template file
--- @param callback ContentHandler # What to do when the content is fetch (before cached)
function M.curl(url, callback)
  job:new({
    command = "curl",
    args = { "-s", "-L", url },
    on_exit = function(j, code)
      local content = (code == 0) and table.concat(j:result(), "\n") or nil
      vim.schedule(
        function()
          callback(content)
        end
      )
    end,
  }):start()
end

return M
