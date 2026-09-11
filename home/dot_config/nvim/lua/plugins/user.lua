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
}
