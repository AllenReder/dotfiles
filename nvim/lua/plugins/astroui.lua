-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "astrodark",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        Normal = { bg = "none" },
        NormalNC = { bg = "none" },
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        SignColumn = { bg = "none" },
        EndOfBuffer = { bg = "none" },
        FoldColumn = { bg = "none" },
        StatusLine = { bg = "none" },
        WinBar = { bg = "none" },
        WinBarNC = { bg = "none" },
        NeoTreeNormal = { bg = "none" },
        NeoTreeNormalNC = { bg = "none" },
        NeoTreeWinSeparator = { bg = "none" },
        NvimTreeNormal = { bg = "none" },
        NvimTreeNormalNC = { bg = "none" },
        NvimTreeWinSeparator = { bg = "none" },
        NeoTreeTabActive = { bg = "none" },
        NeoTreeTabInactive = { bg = "none" },
        NeoTreeTabSeparatorActive = { bg = "none" },
        NeoTreeTabSeparatorInactive = { bg = "none" },
        NeoTreeTitleBar = { bg = "none" },
        BufferLineFill = { bg = "none" },
        BufferLineBackground = { bg = "none" },
        BufferLineTab = { bg = "none" },
        BufferLineTabSelected = { bg = "none" },
        BufferLineTabSeparator = { bg = "none" },
        BufferLineTabSeparatorSelected = { bg = "none" },
        BufferLineSeparator = { bg = "none" },
        BufferLineSeparatorSelected = { bg = "none" },
        BufferLineIndicatorSelected = { bg = "none" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
