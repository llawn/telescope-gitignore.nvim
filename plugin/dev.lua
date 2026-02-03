vim.api.nvim_create_user_command("GitignoreReload", function()
  -- Unload all modules related to this plugin
  for name, _ in pairs(package.loaded) do
    if name:match("^telescope%-gitignore") or name:match("^telescope%._extensions%.gitignore") then
      package.loaded[name] = nil
    end
  end

  -- Re-load the extension
  local ok, err = pcall(require("telescope").load_extension, "gitignore")

  if ok then
    vim.notify("Gitignore Extension Reloaded!", vim.log.levels.INFO)
    -- Automatically open the picker to see changes
    require("telescope").extensions.gitignore.gitignore()
  else
    vim.notify("Reload failed: " .. tostring(err), vim.log.levels.ERROR)
  end
end, { desc = "Hot-reload telescope-gitignore during development" })
