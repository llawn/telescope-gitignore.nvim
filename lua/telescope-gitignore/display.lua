local entry_display = require("telescope.pickers.entry_display")
local devicons = require("nvim-web-devicons")

local M = {}

local gitignore_to_ft = {
  ["Actionscript"] = "asc",
  ["ArchLinuxPackages"] = "arch",
  ["CUDA"] = "cu",
  ["Clojure"] = "clj",
  ["Elisp"] = "el",
  ["Elixir"] = "ex",
  ["Erlang"] = "erl",
  ["Flutter"] = "dart",
  ["Fortran"] = "f90",
  ["Haskell"] = "hs",
  ["Haxe"] = "hx",
  ["Julia"] = "jl",
  ["KiCad"] = "kicad_pcb",
  ["Kotlin"] = "kt",
  ["LabVIEW"] = "vi",
  ["OCaml"] = "ml",
  ["Perl"] = "pl",
  ["Python"] = "py",
  ["ReScript"] = "res",
  ["Ruby"] = "rb",
  ["Rust"] = "rs",
  ["Scheme"] = "scm",
  ["Solidity-Remix"] = "sol",
  ["Terraform"] = "tf",
}

local icon_nf = {
  ["Angular"]              = { logo = "󰚲", color = 0xb52e31 },
  ["AppceleratorTitanium"] = { logo = "", color = 0xb11b31 },
  ["Ballerina"]            = { logo = "󱗊", color = 0x20b6b0 },
  ["CakePHP"]              = { logo = "", color = 0xd43d47 },
  ["CFWheels"]             = { logo = "" },
  ["CodeIgniter"]          = { logo = "", color = 0xf14e37 },
  ["CommonLisp"]           = { logo = "" },
  ["Composer"]             = { logo = "" },
  ["Dotnet"]               = { logo = "󰪮", color = 0xd59dff },
  ["Drupal"]               = { logo = "", color = 0x0073b9 },
  ["Firebase"]             = { logo = "", color = 0xffcb2b },
  ["GitBook"]              = { logo = "", color = 0x3880fc },
  ["GitHubPages"]          = { logo = "", color = 0x000000 },
  ["Grails"]               = { logo = "", color = 0xfeb571 },
  ["JENKINS_HOME"]         = { logo = "" },
  ["Jekyll"]               = { logo = "", color = 0xd50000 },
  ["Joomla"]               = { logo = "", color = 0x5091cd },
  ["Laravel"]              = { logo = "", color = 0xfb2616 },
  ["Magento"]              = { logo = "", color = 0xec4b18 },
  ["Maven"]                = { logo = "", color = 0xe67621 },
  ["Nestjs"]               = { logo = "", color = 0xee1744 },
  ["Nextjs"]               = { logo = "" },
  ["Node"]                 = { logo = "󰎙", color = 0x3d6639 },
  ["Objective-C"]          = { logo = "", color = 0xfa5828 },
  ["OpenCart"]             = { logo = "", color = 0x48b4e4 },
  ["OracleForms"]          = { logo = "", color = 0xea1a20 },
  ["Packer"]               = { logo = "", color = 0x02a8ef },
  ["Phalcon"]              = { logo = "", color = 0x76c29c },
  ["Processing"]           = { logo = "" },
  ["PureScript"]           = { logo = "" },
  ["Qt"]                   = { logo = "", color = 0x28de84 },
  ["Rails"]                = { logo = "󰫏", color = 0xcc0000 },
  ["ROS"]                  = { logo = "", color = 0x21314e },
  ["Salesforce"]           = { logo = "󰢎", color = 0x00a1e1 },
  ["Symfony"]              = { logo = "󰫦" },
  ["Typo3"]                = { logo = "", color = 0xff8700 },
  ["Unity"]                = { logo = "󰚯", color = 0x4c4c4c },
  ["UnrealEngine"]         = { logo = "󰦱" },
  ["VBA"]                  = { logo = "󱎏", color = 0x33c481 },
  ["VisualStudio"]         = { logo = "󰘐", color = 0xd59dff },
  ["WordPress"]            = { logo = "", color = 0x00749c },
  ["Yeoman"]               = { logo = "" },
  ["Yii"]                  = { logo = "", color = 0xd8582b },
  ["ZendFramework"]        = { logo = "", color = 0x67B701 },
  ["Zephir"]               = { logo = "󱥒" },
}

--- @class TelescopeGitignoreEntry
--- @field value GitignoreTemplate The underlying template data
--- @field ordinal string The string used for searching/sorting
--- @field name string The display name
--- @field display function The function that renders the UI line

--- @alias TelescopeGitignoreDisplayer fun(entry: TelescopeGitignoreEntry): string, table[] # Returns display string and highlight map

--- This is the custom entry_display for the TelescopeGitignore menu
--- It adds icon to some gitignore templates
--- @return TelescopeGitignoreDisplayer
function M.gen_make_display()
  local displayer = entry_display.create({
    separator = " ",
    items = { { width = 2 }, { remaining = true } },
  })

  return function(entry)
    local name = entry.name
    local nf = icon_nf[name]
    local icon, hl

    if nf then
      -- Custom NerdFont icon with custom highlighter color
      icon = nf.logo
      hl = "TelescopeGitignore" .. name
      vim.api.nvim_set_hl(0, hl, { fg = nf.color or 0xffffff })
    else
      -- Fallback DevIcons standard
      local ext = gitignore_to_ft[name] or "gitignore"
      icon, hl = devicons.get_icon(name, ext, { default = true })
    end

    return displayer({
      { icon, hl },
      name,
    })
  end
end

return M
