return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

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

      -- Seed the random number generator
      math.randomseed(os.time())
      return files[math.random(#files)]
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
      return lines
    end

    local ascii_art_directory = vim.fn.stdpath("config") .. "/lua/josue/ascii_art"
    local random_file = get_random_file(ascii_art_directory)

    dashboard.section.header.val = read_ascii_art(random_file)

    dashboard.section.header.opts.position = "center"
    dashboard.section.header.opts.hl = "AlphaHeader"

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button("e", "  > New File", "<cmd>ene<CR>"),
      dashboard.button("SPC ee", "  > Toggle file explorer", "<cmd>NvimTreeToggle<CR>"),
      dashboard.button("SPC ff", "󰱼  > Find File", "<cmd>Telescope find_files<CR>"),
      dashboard.button("SPC fs", "  > Find Word", "<cmd>Telescope live_grep<CR>"),
      dashboard.button("SPC wr", "󰁯  > Restore Session For Current Directory", "<cmd>SessionRestore<CR>"),
      dashboard.button("q", "  > Quit NVIM", "<cmd>qa<CR>"),
    }

    dashboard.section.buttons.opts.position = "center"

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
