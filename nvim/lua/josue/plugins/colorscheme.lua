return {
   {
    "xiyaowong/transparent.nvim",
    priority = 1001, -- Higher priority than kanagawa
    config = function()
      require("transparent").setup({
        enable = true,
        extra_groups = {
          "Normal",
          "NormalNC",
          "Comment",
          "Constant",
          "Special",
          "Identifier",
          "Statement",
          "PreProc",
          "Type",
          "Underlined",
          "Todo",
          "String",
          "Function",
          "Conditional",
          "Repeat",
          "Operator",
          "Structure",
          "LineNr",
          "NonText",
          "SignColumn",
          "CursorLineNr",
          "EndOfBuffer",
        },
        exclude = {}, -- table: groups you don't want to clear
      })
    end,
   },
   {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    priority = 1000, -- High priority to ensure it loads early
    opts = {
      transparent = true, -- Enable transparent background
      theme = "dragon", -- Set the theme variant to 'dragon'
      overrides = function(colors)
        local theme = colors.theme
        return {
          Normal = { bg = "none" },
          NormalFloat = { bg = "none" }, -- Transparent background for floating windows
          FloatBorder = { bg = "none" }, -- Transparent background for floating window borders
          FloatTitle = { bg = "none" }, -- Transparent background for floating window titles
          NormalDark = { fg = theme.ui.fg_dim, bg = "none" }, -- Custom colors for dark mode
          LazyNormal = { bg = "none", fg = theme.ui.fg_dim }, -- Custom colors for Lazy plugin
          MasonNormal = { bg = "none", fg = theme.ui.fg_dim }, -- Custom colors for Mason plugin
          FzfLuaNormal = { fg = theme.ui.fg_dim, bg = "none" }, -- Custom colors for FzfLua normal
          FzfLuaBorder = { fg = theme.ui.bg_m1, bg = "none" }, -- Custom colors for FzfLua border
          FzfLuaTitle = { fg = theme.ui.special, bold = true }, -- Custom colors for FzfLua title
          Pmenu = { fg = theme.ui.shade0, bg = "none" }, -- Custom colors for popup menu
          PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 }, -- Custom colors for selected item in popup menu
          PmenuSbar = { bg = theme.ui.bg_m1 }, -- Custom colors for popup menu scrollbar
          PmenuThumb = { bg = theme.ui.bg_p2 }, -- Custom colors for popup menu thumb 
        }
      end,
    },
    config = function()
      vim.cmd("colorscheme kanagawa")
      -- Enable transparency after loading the theme
      vim.cmd("TransparentEnable")

      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#b026ff", bold = true, sp = "#b026ff" }) 
      vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
    end,
  },
 }
