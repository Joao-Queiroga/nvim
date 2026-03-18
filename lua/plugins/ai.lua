---@type PluginList
return {
  {
    "codecompanion.nvim",
    after = function()
      require("codecompanion").setup({
        extensions = {
          history = {
            enabled = true,
          },
          spinner = {},
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_tools = true,
              show_server_tools_in_chat = true,
              add_mcp_prefix_to_tool_names = false,
              show_result_in_chat = true,
              make_vars = false,
              make_slash_commands = true,
            },
          },
        },
      })
    end,
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanionHistory",
      "CodeCompanionSummaries",
    },
  },
  {
    "codecompanion-spinner.nvim",
    lazy = true,
    dep_of = { "codecompanion.nvim" },
  },
  {
    "codecompanion-history.nvim",
    lazy = true,
    dep_of = { "codecompanion.nvim" },
  },
  {
    "mcphub.nvim",
    after = function()
      require("mcphub").setup({})
    end,
    cmd = { "MCPHub" },
    on_require = { "mcphub.extensions.codecompanion" },
  },
  {
    "copilot.lua",
    after = function()
      require("copilot").setup({})
    end,
    cmd = { "Copilot" },
    dep_of = { "codecompanion.nvim" },
  },
}
