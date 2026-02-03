-- plugin/telescope-gitignore.lua

if vim.g.loaded_telescope_gitignore == 1 then
  return
end
vim.g.loaded_telescope_gitignore = 1

-- Create a top-level command for convenience
vim.api.nvim_create_user_command("Gitignore", function()
  -- This will automatically trigger the extension load if it hasn't happened
  require("telescope").extensions.gitignore.gitignore()
end, { desc = "Telescope Gitignore" })
