return {
  "vyfor/cord.nvim",
  run = ":Cord update",
  event = "VeryLazy",
  config = function()
    local cord = require("cord")

    -- local quotes = {
    --   "GTA VI came out before my Rust program finished compiling. ⏳",
    --   "When your code works on the first try. 😱",
    --   "It’s not a bug, it’s a feature. 🐛✨",
    --   "I don’t always test my code, but when I do, I do it in production. 💥",
    --   "My code works, I have no idea why. 🤷‍♂️",
    --   "Hello from the other side... of a merge conflict. 🔀",
    --   "If it works, don’t touch it. 🛑",
    --   "May your code never compile on the first try. 🤞",
    --  }
    --
    local get_errors = function(bufnr)
      return vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
    end

    local get_warnings = function(bufnr)
      return vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
    end

    local errors = get_errors(0) -- pass the current buffer; pass nil to get errors for all buffers
    local warnings = get_warnings(0)

    vim.api.nvim_create_autocmd("DiagnosticChanged", {
      callback = function()
        errors = get_errors(0)
        warnings = get_warnings(0)
      end,
    })

    cord.setup({
      enabled = true,
      log_level = vim.log.levels.OFF,
      editor = {
        client = "neovim",
        tooltip = "neoFUCK",
        icon = nil,
      },
      display = {
        theme = "catppuccin",
        flavor = "dark",
        swap_fields = false,
        swap_icons = false,
      },
      timestamp = {
        enabled = true,
        reset_on_idle = false,
        reset_on_change = false,
      },
      idle = {
        enabled = true,
        timeout = 300000,
        show_status = true,
        ignore_focus = true,
        unidle_on_focus = true,
        smart_idle = true,
        details = "Idling",
        state = nil,
        tooltip = "💤",
        icon = nil,
      },
      text = {
        workspace = function(opts)
          local hour = tonumber(os.date("%H"))
          local status = hour >= 22 and "🌙 Late night coding"
            or hour >= 18 and "🌆 Evening session"
            or hour >= 12 and "☀️ Afternoon coding"
            or hour >= 5 and "🌅 Morning productivity"
            or "🌙 Midnight hacking"

          return string.format("%s: %s", status, opts.workspace)
        end,
        viewing = function(opts)
          return "viewing " .. opts.filename
        end,
        editing = function(opts)
          local message = (#errors > 0 and string.format("%s errors", #errors))
            or (#warnings > 0 and string.format("%s warnings", #warnings))
            or "no issues"

          return string.format("Editing %s - %s", opts.filename, message)
        end,
        file_browser = function(opts)
          return "browsing files in " .. opts.name
        end,
        plugin_manager = function(opts)
          return "managing plugins in " .. opts.name
        end,
        lsp = function(opts)
          return "configuring LSP in " .. opts.name
        end,
        docs = function(opts)
          return "reading " .. opts.name
        end,
        vcs = function(opts)
          return "Committing changes in " .. opts.name
        end,
        notes = function(opts)
          return "taking notes in " .. opts.name
        end,
        debug = function(opts)
          return "debugging in " .. opts.name
        end,
        test = function(opts)
          return "testing in " .. opts.name
        end,
        diagnostics = function(opts)
          return #vim.diagnostics.get(vim.api.nvim_get_current_buf()) > 0 and "Fixing problems in " .. opts.tooltip
            or true
        end,
        games = function(opts)
          return "playing " .. opts.name
        end,
        terminal = function(opts)
          return "running commands in " .. opts.name
        end,
        dashboard = "neoFUCK",
      },
      buttons = {
        -- {
        --   label = function(opts)
        --     return opts.repo_url and "View Repository" or "My Website"
        --   end,
        --   url = function(opts)
        --     return opts.repo_url or "https://example.com"
        --   end,
        -- },
      },
      assets = nil,
      variables = nil,
      hooks = {
        ready = nil,
        shutdown = nil,
        pre_activity = nil,
        post_activity = nil,
        idle_enter = nil,
        idle_leave = nil,
        workspace_change = nil,
      },
      plugins = nil,
      advanced = {
        plugin = {
          autocmds = true,
          cursor_update = "on_hold",
          match_in_mappings = true,
        },
        server = {
          update = "fetch",
          pipe_path = nil,
          executable_path = nil,
          timeout = 300000,
        },
        discord = {
          reconnect = {
            enabled = true,
            interval = 5000,
            initial = true,
          },
        },
      },
    })
  end,
}
