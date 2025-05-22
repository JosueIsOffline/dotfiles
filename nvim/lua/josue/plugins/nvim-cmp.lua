return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")

    local luasnip = require("luasnip")

    local lspkind = require("lspkind")

    require("luasnip.loaders.from_vscode").lazy_load()

    local lsp_kinds = {
      Class = " ",
      Color = " ",
      Constant = " ",
      Constructor = " ",
      Enum = " ",
      EnumMember = " ",
      Event = " ",
      Field = " ",
      File = " ",
      Folder = " ",
      Function = " ",
      Interface = " ",
      Keyword = " ",
      Method = " ",
      Module = " ",
      Operator = " ",
      Property = " ",
      Reference = " ",
      Snippet = " ",
      Struct = " ",
      Text = " ",
      TypeParameter = " ",
      Unit = " ",
      Value = " ",
      Variable = " ",
    }

    cmp.setup({
      completion = { completeopt = "menu,menuone,preview,noselect" },
      snippet = { -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
        ["<C-e>"] = cmp.mapping.abort(), -- close completion window
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      }),
      -- sources for autocompletion
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "nvim_lsp" },
        { name = "luasnip" }, -- snippets
        { name = "buffer" }, -- text within current buffer
        { name = "path" }, -- file system paths
      }),

      -- configure lspkind for vs-code like pictograms in completion menu
      formatting = {
        -- format = lspkind.cmp_format({
        -- xwidth = 50,
        --   ellipsis_char = "...",
        -- }),
        format = function(entry, vim_item)
          lspkind.cmp_format({
            xwidth = 50,
            ellipsis_char = "...",
          })
          -- set `kind` to "$icon $kind"
          vim_item.kind = string.format("%s %s", lsp_kinds[vim_item.kind], vim_item.kind)
          vim_item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[LuaSnip]",
            nvim_lua = "[Lua]",
            latex_symbols = "[LaTex]",
          })[entry.source.name]
          return vim_item
        end,
      },

      window = {
        completion = cmp.config.window.bordered({
          border = "rounded",
          col_offset = -1,
          scrollbar = false,
          scrolloff = 3,
          -- Default for bordered() is 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
          -- Default for non-bordered, which we'll use here, is:
          winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:PmenuSel,Search:None",
        }),
        documentation = cmp.config.window.bordered({
          border = "rounded",
          scrollbar = false,
          -- Default for bordered() is 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
          -- Default for non-bordered is 'FloatBorder:NormalFloat'
          -- Suggestion from: https://github.com/hrsh7th/nvim-cmp/issues/2042
          -- is to use 'NormalFloat:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
          -- but this also seems to suffice:
          winhighlight = "Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None",
        }),
      },
    })
  end,
}
