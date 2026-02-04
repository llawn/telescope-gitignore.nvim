# telescope-gitignore.nvim

![GitHub License](https://img.shields.io/github/license/llawn/telescope-gitignore.nvim)
![GitHub repo size](https://img.shields.io/github/repo-size/llawn/telescope-gitignore.nvim)
![GitHub Tag](https://img.shields.io/github/v/tag/llawn/telescope-gitignore.nvim)
![Neovim Version](https://img.shields.io/badge/Neovim-0.11+-57A143)

**telescope-gitignore.nvim** is a [Telescope](https://github.com/nvim-telescope/telescope.nvim) extension that allows you to browse and select
.gitignore templates from the official [github/gitignore](https://github.com/github/gitignore) repository.

Features:
- Browse gitignore templates from GitHub's official collection
- Preview template content before selection
- Works offline with cached templates
- Customizable selection behavior
- Automatic caching for performance

![telescope-gitignore-example](https://github.com/user-attachments/assets/8e5b4936-869d-42ff-a874-602ecc5a67e6)

## Install

### `lazy.nvim`

```lua
{
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'llawn/telescope-gitignore.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require("telescope").load_extension("gitignore")
  end
}

```

### Neovim 0.12+ (vim.pack)

```lua
-- Add plugins to your config
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/llawn/telescope-gitignore.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

-- Setup telescope and load extension
require("telescope").setup({})
require("telescope").load_extension("gitignore")
```

### Dependencies

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- `curl` command-line tool (for fetching templates from GitHub)

## Setup

### Advanced Configuration

```lua
local telescope = require('telescope')

telescope.setup({
  extensions = {
    gitignore = {
      cache_dir = vim.fn.stdpath("data") .. "/telescope-gitignore",
      github_api_url = "https://api.github.com/repos/github/gitignore/contents/",
      notifications = true,
      prompt_title = "Gitignore Templates",
      offline_prompt_title = "Gitignore Templates (Offline)",
      on_select = function(name, content)
        -- Custom behavior when template is selected
        local path = vim.fn.getcwd() .. "/.gitignore"
        local f = io.open(path, "a+")

        if f then
          f:write("\n" .. content .. "\n")
          f:close()
        else
          vim.notify("Error: Unable to write to .gitignore", vim.log.levels.ERROR)
        end
      end,
    },
  }
})

-- --- Keybindings ---
vim.keymap.set('n', '<leader>fgt', telescope.extensions.gitignore.gitignore, { desc = 'Gitignore Templates' })
```

### Configuration Options

| Option | Default | Description |
| --- | --- | --- |
| `cache_dir` | `vim.fn.stdpath("data") .. "/telescope-gitignore"` | Directory to cache downloaded templates |
| `github_api_url` | `"https://api.github.com/repos/github/gitignore/contents/"` | GitHub API URL for templates |
| `notifications` | `true` | Show notifications when templates are added |
| `prompt_title` | `"Gitignore Templates"` | Title for the telescope picker |
| `offline_prompt_title` | `"Gitignore Templates (Offline)"` | Title when offline |
| `on_select` | `function(name, content)` | Callback when template is selected |

## Usage

### Commands

| Command | Description |
| --- | --- |
| `:Gitignore` | Open the gitignore template picker |
| `:Telescope gitignore` | Alternative command to open the picker |


## How it Works

1. **Online Mode**: Fetches available templates from GitHub's gitignore repository API
2. **Caching**: Downloaded templates are cached locally for offline use
3. **Preview**: Shows template content in a preview pane before selection
4. **Offline Mode**: Falls back to cached templates when network is unavailable
5. **Custom Actions**: Configurable callback function for template selection behavior

### Technical Note: Asynchronous "Push" Architecture

This plugin uses an asynchronous "push-based" architecture to ensure that Neovim never freezes while fetching data from GitHub when using curl.

## Example Workflow

1. Run `:Gitignore` or `:Telescope gitignore`
2. Search for a template (e.g., "Node", "Python", "Go")
3. Preview the template content in the right pane
4. Press `<Enter>` to add it to your project's `.gitignore` file

## License

MIT License - see [LICENSE](https://github.com/llawn/telescope-gitignore.nvim/blob/main/LICENSE)
