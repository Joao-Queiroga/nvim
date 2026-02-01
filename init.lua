vim.loader.enable()
do
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)
  if not ok then
    package.loaded[vim.g.nix_info_plugin_name] = setmetatable({}, {
      __call = function(_, default)
        return default
      end,
    })
    _G.nixInfo = require(vim.g.nix_info_plugin_name)
  end
  nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil
  nixInfo.get_nix_plugin_path = function(name)
    return nixInfo(nil, "plugins", "lazy", name) or nixInfo(nil, "plugins", "start", name)
  end
end

if vim.env.PROF then
  vim.cmd.packadd("snacks.nvim")
  require("snacks.profiler").startup({
    startup = {
      event = "UIEnter",
    },
  })
end

vim.cmd.colorscheme("tokyonight-night")
require("config.settings")
require("config.options")
require("config.lsp")
require("config.keybindings")
require("config.autocmd")
require("plugins")
