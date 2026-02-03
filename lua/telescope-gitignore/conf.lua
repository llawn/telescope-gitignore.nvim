local M = {}

M.defaults = {
  cache_dir = vim.fn.stdpath("data") .. "/telescope-gitignore",
  github_api_url = "https://api.github.com/repos/github/gitignore/contents/",
  notifications = true,
  prompt_title = "Gitignore Templates",
  offline_prompt_title = "Gitignore Templates (Offline)",

  --- Action when selecting a gitignore templates in the telescope menu
  --- By defaults, it adds the content to cwd .gitignore
  --- @param name string
  --- @param content string
  --- @return nil
  on_select = function(name, content)
    local path = vim.fn.getcwd() .. "/.gitignore"
    local header = string.format("\n# --- %s --- \n", name)
    local full_content = header .. content .. "\n"

    local f = io.open(path, "a+")
    if not f then
      return vim.notify("Error: Unable to write to .gitignore", vim.log.levels.ERROR)
    end

    f:write(full_content)
    f:close()

    if M.get_config().notifications then
      vim.notify("Added: " .. name, vim.log.levels.INFO)
    end
  end,
}

M.config = {}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
  if vim.fn.isdirectory(M.config.cache_dir) == 0 then
    vim.fn.mkdir(M.config.cache_dir, "p")
  end
  return M.config
end

function M.get_config()
  return next(M.config) and M.config or M.setup(nil)
end

return M
