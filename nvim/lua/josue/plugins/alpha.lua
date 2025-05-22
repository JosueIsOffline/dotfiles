return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local M = {}

    local path_ok, plenary_path = pcall(require, "plenary.path")
    if not path_ok then
      return
    end

    local cdir = vim.fn.getcwd()
    local if_nil = vim.F.if_nil

    local nvim_web_devicons = {
      enabled = true,
      highlight = true,
    }

    local function get_extension(fn)
      local match = fn:match("^.+(%..+)$")
      local ext = ""
      if match ~= nil then
        ext = match:sub(2)
      end
      return ext
    end

    local function icon(fn)
      local nwd = require("nvim-web-devicons")
      local ext = get_extension(fn)
      return nwd.get_icon(fn, ext, { default = true })
    end

    local function file_button(fn, sc, short_fn, autocd)
      short_fn = short_fn or fn
      local ico_txt
      local fb_hl = {}

      if nvim_web_devicons.enabled then
        local ico, hl = icon(fn)
        local hl_option_type = type(nvim_web_devicons.highlight)
        if hl_option_type == "boolean" then
          if hl and nvim_web_devicons.highlight then
            table.insert(fb_hl, { hl, 0, #ico })
          end
        end
        if hl_option_type == "string" then
          table.insert(fb_hl, { nvim_web_devicons.highlight, 0, #ico })
        end
        ico_txt = ico .. "  "
      else
        ico_txt = ""
      end
      local cd_cmd = (autocd and " | cd %:p:h" or "")
      local file_button_el =
        dashboard.button(sc, ico_txt .. short_fn, "<cmd>e " .. vim.fn.fnameescape(fn) .. cd_cmd .. " <CR>")
      local fn_start = short_fn:match(".*[/\\]")
      if fn_start ~= nil then
        table.insert(fb_hl, { "Comment", #ico_txt - 2, #fn_start + #ico_txt })
      end
      file_button_el.opts.hl = fb_hl
      return file_button_el
    end

    local default_mru_ignore = { "gitcommit" }

    local mru_opts = {
      ignore = function(path, ext)
        return (string.find(path, "COMMIT_EDITMSG")) or (vim.tbl_contains(default_mru_ignore, ext))
      end,
      autocd = false,
    }

    --- @param start number
    --- @param cwd string? optional
    --- @param items_number number? optional number of items to generate, default = 6
    local function mru(start, cwd, items_number, opts)
      opts = opts or mru_opts
      items_number = if_nil(items_number, 6)

      local oldfiles = {}
      for _, v in pairs(vim.v.oldfiles) do
        if #oldfiles == items_number then
          break
        end
        local cwd_cond
        if not cwd then
          cwd_cond = true
        else
          cwd_cond = vim.startswith(v, cwd)
        end
        local ignore = (opts.ignore and opts.ignore(v, get_extension(v))) or false
        if (vim.fn.filereadable(v) == 1) and cwd_cond and not ignore then
          oldfiles[#oldfiles + 1] = v
        end
      end
      local target_width = 35

      local tbl = {}
      for i, fn in ipairs(oldfiles) do
        local short_fn
        if cwd then
          short_fn = vim.fn.fnamemodify(fn, ":.")
        else
          short_fn = vim.fn.fnamemodify(fn, ":~")
        end

        if #short_fn > target_width then
          short_fn = plenary_path.new(short_fn):shorten(1, { -2, -1 })
          if #short_fn > target_width then
            short_fn = plenary_path.new(short_fn):shorten(1, { -1 })
          end
        end

        local shortcut = tostring(i + start - 1)

        local file_button_el = file_button(fn, shortcut, short_fn, opts.autocd)
        tbl[i] = file_button_el
      end
      return {
        type = "group",
        val = tbl,
        opts = {},
      }
    end

    -- Header config section
    local function ensure_directory_exists(directory)
      if vim.fn.isdirectory(directory) ~= 1 then
        print("Creating ASCII art directory: " .. directory)
        vim.fn.mkdir(directory, "p")

        -- Create a default ASCII art file
        local default_file = directory .. "/default_art.txt"
        local file = io.open(default_file, "w")
        if file then
          file:write([[
  ╭──────────────────────────────────────────╮
  │                                          │
  │   Welcome to Neovim!                     │
  │                                          │
  │   Add your own ASCII art files to:       │
  │   ]] .. directory .. [[ │
  │                                          │
  │   They will be displayed randomly        │
  │   each time you start Neovim!            │
  │                                          │
  ╰──────────────────────────────────────────╯
  ]])
          file:close()
          return true
        else
          print("Failed to create default ASCII art file")
          return false
        end
      end
      return true
    end

    local function get_files_in_directory(directory)
      local files = {}
      -- Check if directory exists, create it if it doesn't
      if not ensure_directory_exists(directory) then
        print("ASCII art directory does not exist: " .. directory)
        return files -- Return empty table if directory doesn't exist
      end

      -- Use vim.fn.glob which is more reliable than io.popen
      local pattern = directory .. "/*"
      local globbed_files = vim.fn.glob(pattern, false, true)

      if #globbed_files == 0 then
        print("No files found in ASCII art directory: " .. directory)
      end

      return globbed_files
    end

    local function get_random_file(directory)
      local files = get_files_in_directory(directory)
      if #files == 0 then
        print("No files to select from in: " .. directory)
        return nil
      end

      -- Create a new array containing only regular files (not directories)
      local regular_files = {}
      for _, file_path in ipairs(files) do
        if vim.fn.isdirectory(file_path) ~= 1 then
          table.insert(regular_files, file_path)
        end
      end

      if #regular_files == 0 then
        print("No regular files found in: " .. directory)
        return nil
      end

      -- Seed the random number generator
      math.randomseed(os.time())
      return regular_files[math.random(#regular_files)]
    end

    local function read_ascii_art(file_path)
      -- Check if file exists and is readable
      local file = io.open(file_path, "r")
      if not file then
        -- Return a fallback ASCII art if file can't be opened
        return {
          "  No ASCII art found  ",
          "       ¯\\_(ツ)_/¯     ",
        }
      end

      local lines = {}
      for line in file:lines() do
        table.insert(lines, line)
      end
      file:close()
      -- return lines

      -- Balance the ASCII art by finding and removing consistent leading spaces
      local min_spaces = math.huge
      for _, line in ipairs(lines) do
        -- Skip empty lines when calculating minimum spaces
        if line:match("%S") then
          local leading_spaces = line:match("^(%s*)"):len()
          min_spaces = math.min(min_spaces, leading_spaces)
        end
      end

      -- Apply the trimming to each line
      local balanced_lines = {}
      for _, line in ipairs(lines) do
        if min_spaces > 0 and line:len() >= min_spaces then
          table.insert(balanced_lines, line:sub(min_spaces + 1))
        else
          table.insert(balanced_lines, line)
        end
      end

      return balanced_lines
    end

    local ascii_art_directory = vim.fn.stdpath("config") .. "/lua/josue/ascii_art"
    local random_file = get_random_file(ascii_art_directory)

    local header = {
      type = "text",
      val = read_ascii_art(random_file),
      opts = {
        position = "center",
        hl = "AlphaHeader",
        -- wrap = "overflow";
      },
    }
    function M.shortcuts()
      local keybind_opts = { silent = true, noremap = true }
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = { "AlphaReady" },
        callback = function(_)
          vim.api.nvim_buf_set_keymap(0, "n", "z", ":Lazy<CR>", keybind_opts)
          vim.api.nvim_buf_set_keymap(
            0,
            "n",
            "l",
            ":lua require('toggleterm.terminal').Terminal:new({cmd = 'lazygit', direction = 'float'}):toggle()<cr>",
            keybind_opts
          )
          vim.api.nvim_buf_set_keymap(0, "n", "m", ":Mason<CR>", keybind_opts)

          -- Quit
          vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>q<CR>", keybind_opts)
          vim.api.nvim_buf_set_keymap(0, "n", "h", "<cmd>q<CR>", keybind_opts)
        end,
      })
      return {
        {
          type = "text",
          val = {
            -- "ﯠ Harpoon [h]    פּ Nvim-Tree [e]    鈴 Lazy [z]     Quit [q]",
            " Lazy [l]    󰺾 Mason [m]    鈴 Lazy [z]      Quit [q]",
          },
          opts = {
            position = "center",
            hl = {
              { "Constant", 1, 20 },
              { "Keyword", 20, 38 },
              { "Function", 38, 50 },
              { "AlphaQuit", 51, 70 },
            },
          },
        },
      }
    end

    M.section_shortcuts = { type = "group", val = M.shortcuts }

    function M.info_text()
      ---@diagnostic disable-next-line:undefined-field
      local datetime = os.date(" %Y-%m-%d   %A")
      local lazy_stats = require("lazy").stats()
      local ms = (math.floor(lazy_stats.startuptime * 100 + 0.5) / 100)
      local total_plugins = "  " .. lazy_stats.loaded .. "/" .. lazy_stats.count .. " in " .. ms .. " ms"
      local version = vim.version()
      local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = { "LazyVimStarted" },
        callback = function()
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
      return datetime .. total_plugins .. nvim_version_info
    end

    M.section_info = {
      type = "text",
      val = function()
        return M.info_text()
      end,
      opts = {
        hl = "AlphaInfo",
        position = "center",
      },
    }

    local section_mru = {
      type = "group",
      val = {
        {
          type = "text",
          val = "Recent files",
          opts = {
            hl = "SpecialComment",
            shrink_margin = false,
            position = "center",
          },
        },
        { type = "padding", val = 1 },
        {
          type = "group",
          val = function()
            return { mru(0, cdir) }
          end,
          opts = { shrink_margin = false },
        },
      },
    }

    local buttons = {
      type = "group",
      val = {
        { type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
        { type = "padding", val = 1 },
        dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
        dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
        dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
        dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
        -- dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
      },
      position = "center",
    }
    local footer = {
      type = "text",
      val = function()
        return "[" .. cdir .. "]"
      end,
      opts = {
        position = "center",
        hl = "AlphaFooter",
      },
    }

    local config = {
      layout = {
        { type = "padding", val = 1 },
        header,
        { type = "padding", val = 1 },
        M.section_shortcuts,
        { type = "padding", val = 1 },
        M.section_info,
        { type = "padding", val = 1 },
        section_mru,
        { type = "padding", val = 1 },
        buttons,
        { type = "padding", val = 2 },
        footer,
      },
      opts = {
        margin = 5,
        setup = function()
          vim.api.nvim_create_autocmd("DirChanged", {
            pattern = "*",
            group = "alpha_temp",
            callback = function()
              cdir = vim.fn.getcwd()
              require("alpha").redraw()
              vim.cmd("AlphaRemap")
            end,
          })
        end,
      },
    }

    -- Send config to alpha
    alpha.setup(config)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
