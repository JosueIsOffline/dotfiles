return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufAdd", "BufNewFile", "BufRead" },
  opts = {
    css = {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = true, -- "Name" codes like Blue
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      rgb_fn = true, -- CSS rgb() and rgba() functions
      hsl_fn = true, -- CSS hsl() and hsla() functions
      css = true, -- CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
      css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
    },
    html = { mode = "background" },
    markdown = { names = false },
    "yaml",
    lua = { names = false },
    "*",
  },
}
