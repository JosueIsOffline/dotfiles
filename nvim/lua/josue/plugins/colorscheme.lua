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
          "BufferLineFill",
        },
        exclude = {}, -- table: groups you don't want to clear
      })
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "hard", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = true,
      })
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    config = function()
      require("kanagawa").setup({
        compile = false, -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = true, -- do not set background color
        dimInactive = false, -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        colors = { -- add/modify theme and palette colors
          palette = {},
          theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        },
        overrides = function(colors) -- add/modify highlights
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
            TelescopeTitle = { fg = theme.ui.special, bold = true },
            TelescopePromptNormal = { bg = "none" },
            TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = "none" },
            TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = "none" },
            TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = "none" },
            TelescopePreviewNormal = { bg = "none" },
            TelescopePreviewBorder = { bg = "none", fg = theme.ui.bg_dim },
          }
        end,
        theme = "wave", -- Load "wave" theme
        background = { -- map the value of 'background' option to a theme
          dark = "wave", -- try "dragon" !
          light = "lotus",
        },
      })

      -- setup must be called before loading
      local theme = require("utils.colors")
      vim.cmd("colorscheme kanagawa")

      -- Enable transparency after loading the theme
      vim.cmd("TransparentEnable")

      -- Alpha
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#b026ff", bold = true, sp = "#b026ff" })
      vim.api.nvim_set_hl(0, "AlphaKeys", { fg = theme.color43, bg = theme.color0 })
      vim.api.nvim_set_hl(0, "AlphaDesc", { fg = theme.color20, bg = theme.color0 })
      vim.api.nvim_set_hl(0, "AlphaIcon", { fg = theme.color100, bg = theme.color0 })
      vim.api.nvim_set_hl(0, "AlphaQuit", { fg = theme.color16, bg = "none" })
      vim.api.nvim_set_hl(0, "AlphaFoot", { fg = theme.color3, bg = theme.color0 })
      vim.api.nvim_set_hl(0, "AlphaInfo", { fg = theme.color29, bg = "none" })

      -- WhichKey
      -- vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
    end,
  },
}
