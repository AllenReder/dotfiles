return {
  {
    "AstroNvim/astrocore",
    opts = {
      options = {
        opt = {
          number = true,
          relativenumber = false,
          clipboard = "unnamedplus",
        },
      },
      mappings = {
        n = {
          J = { "<C-d>", desc = "Scroll down" },
          K = { "<C-u>", desc = "Scroll up" },
        },
        v = {
          J = { "<C-d>", desc = "Scroll down" },
          K = { "<C-u>", desc = "Scroll up" },
        },
        i = {
          ["jj"] = { "<Esc>", desc = "Exit insert mode" },
        },
      },
    },
  },
  -- DAP stack is unused; disabling these also removes their mappings
  { "mfussenegger/nvim-dap", enabled = false },
  { "rcarriga/nvim-dap-ui", enabled = false },
  { "rcarriga/cmp-dap", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}
