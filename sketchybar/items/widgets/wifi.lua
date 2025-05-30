local icons = require "icons"
local colors = require("colors").sections.widgets.wifi
local settings = require "settings"

-- Execute the event provider binary which provides the event "network_update"
-- for the network interface "en0", which is fired every 2.0 seconds.
sbar.exec "killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0"

local popup_width = 250
local speed_test_in_progress = false

local wifi_up = sbar.add("item", "widgets.wifi1", {
  position = "right",
  padding_left = -5,
  width = 0,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    string = icons.wifi.upload,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.red,
    string = "??? Bps",
  },
  y_offset = 4,
})

local wifi_down = sbar.add("item", "widgets.wifi2", {
  position = "right",
  padding_left = -5,
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    string = icons.wifi.download,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    color = colors.blue,
    string = "??? Bps",
  },
  y_offset = -4,
  background = { drawing = false },
})

local wifi = sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  label = { drawing = false },
  background = { drawing = false },
})

-- Background around the item
local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", {
  wifi.name,
  wifi_up.name,
  wifi_down.name,
}, {
  background = { drawing = false },
  popup = { align = "center", height = 30 },
})

local ssid = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    font = {
      style = settings.font.style_map["Bold"],
    },
    string = icons.wifi.router,
  },
  width = popup_width,
  align = "center",
  label = {
    font = {
      size = 15,
      style = settings.font.style_map["Bold"],
    },
    max_chars = 18,
    string = "????????????",
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -15,
  },
})

local hostname = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Hostname:",
    width = popup_width / 2,
  },
  label = {
    max_chars = 20,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  },
})

local ip = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

local mask = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Subnet mask:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

local router = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

-- Nueva sección para prueba de velocidad
local speed_test_button = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "⚡ Prueba de velocidad",
    width = popup_width,
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -2,
    padding_top = 5,
  },
})

local download_speed = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Velocidad bajada:",
    width = popup_width / 2,
  },
  label = {
    string = "-- Mbps",
    width = popup_width / 2,
    align = "right",
  },
})

local upload_speed = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Velocidad subida:",
    width = popup_width / 2,
  },
  label = {
    string = "-- Mbps",
    width = popup_width / 2,
    align = "right",
  },
})

local ping = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    align = "left",
    string = "Ping:",
    width = popup_width / 2,
  },
  label = {
    string = "-- ms",
    width = popup_width / 2,
    align = "right",
  },
})

-- sbar.add("item", { position = "right", width = settings.group_paddings })

wifi_up:subscribe("network_update", function(env)
  local up_color = (env.upload == "000 Bps") and colors.grey or colors.red
  local down_color = (env.download == "000 Bps") and colors.grey or colors.blue
  wifi_up:set {
    icon = { color = up_color },
    label = {
      string = env.upload,
      color = up_color,
    },
  }
  wifi_down:set {
    icon = { color = down_color },
    label = {
      string = env.download,
      color = down_color,
    },
  }
end)

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
  sbar.exec("ipconfig getifaddr en0", function(ip)
    local connected = not (ip == "")
    wifi:set {
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.white or colors.red,
      },
    }
  end)
end)

local function hide_details()
  wifi_bracket:set { popup = { drawing = false } }
end

local function toggle_details()
  local should_draw = wifi_bracket:query().popup.drawing == "off"
  if should_draw then
    wifi_bracket:set { popup = { drawing = true } }
    sbar.exec("networksetup -getcomputername", function(result)
      hostname:set { label = result }
    end)
    sbar.exec("ipconfig getifaddr en0", function(result)
      ip:set { label = result }
    end)
    sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
      ssid:set { label = result }
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(result)
      mask:set { label = result }
    end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(result)
      router:set { label = result }
    end)
  else
    hide_details()
  end
end

-- Función para ejecutar la prueba de velocidad
local function run_speed_test()
  if speed_test_in_progress then
    return
  end

  speed_test_in_progress = true

  -- Actualizar la interfaz para mostrar que la prueba está en progreso
  speed_test_button:set {
    icon = {
      string = "⏳ Prueba en progreso...",
      color = colors.blue,
    },
  }

  download_speed:set { label = { string = "Midiendo..." } }
  upload_speed:set { label = { string = "Midiendo..." } }
  ping:set { label = { string = "Midiendo..." } }

  -- Ejecutar prueba de velocidad con speedtest-cli
  -- Primero verificamos si está instalado
  sbar.exec("which speedtest-cli", function(result)
    if result == "" then
      -- Mostrar mensaje de error y sugerencia para instalar
      speed_test_button:set {
        icon = {
          string = "❌ speedtest-cli no instalado",
          color = colors.red,
        },
      }
      download_speed:set { label = { string = "Error" } }
      upload_speed:set { label = { string = "Error" } }
      ping:set { label = { string = "Error" } }

      sbar.delay(5, function()
        speed_test_button:set {
          icon = {
            string = "⚡ Prueba de velocidad (instala speedtest-cli)",
            color = colors.white,
          },
        }
        speed_test_in_progress = false
      end)
      return
    end

    -- Ejecutar la prueba usando speedtest-cli
    sbar.exec("speedtest-cli --simple", function(result)
      -- Procesar los resultados
      local download = string.match(result, "Download: ([%d%.]+)")
      local upload = string.match(result, "Upload: ([%d%.]+)")
      local ping_result = string.match(result, "Ping: ([%d%.]+)")

      if download and upload and ping_result then
        download_speed:set { label = { string = download .. " Mbps" } }
        upload_speed:set { label = { string = upload .. " Mbps" } }
        ping:set { label = { string = ping_result .. " ms" } }
      else
        download_speed:set { label = { string = "Error" } }
        upload_speed:set { label = { string = "Error" } }
        ping:set { label = { string = "Error" } }
      end

      -- Restaurar el botón
      speed_test_button:set {
        icon = {
          string = "⚡ Prueba de velocidad",
          color = colors.white,
        },
      }

      speed_test_in_progress = false
    end)
  end)
end

wifi_up:subscribe("mouse.clicked", toggle_details)
wifi_down:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)
speed_test_button:subscribe("mouse.clicked", run_speed_test)

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec('echo "' .. label .. '" | pbcopy')
  sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
download_speed:subscribe("mouse.clicked", copy_label_to_clipboard)
upload_speed:subscribe("mouse.clicked", copy_label_to_clipboard)
ping:subscribe("mouse.clicked", copy_label_to_clipboard)
