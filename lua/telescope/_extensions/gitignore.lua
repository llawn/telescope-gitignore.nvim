return require("telescope").register_extension({
  exports = {
    gitignore = function(opts)
      require("telescope-gitignore.picker").open(opts)
    end,
  },
})
