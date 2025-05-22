local colors = require "colors"
local colors = require("colors").sections.widgets.volume
local icons = require "icons"

local popup_width = 250

local volume_percent = sbar.add("item", "widgets.volume0", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "??%",
    padding_left = -1,
  },
  background = { drawing = false },
})

local volume_icon = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    color = colors.icon,
  },
  label = { drawing = false },
  background = { drawing = false },
  popup = {
    align = "center",
    y_offset = 2,
  },
  padding_right = -1,
})

local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", {
  volume_icon.name,
  volume_percent.name,
}, {
  popup = { align = "center" },
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume_bracket.name,
  slider = {
    highlight_color = colors.slider.highlight,
    background = {
      height = 12,
      corner_radius = 6,
      color = colors.slider.bg,
      border_color = colors.slider.border,
      border_width = 2,
    },
    knob = {
      string = "􀀁",
      drawing = true,
    },
  },
  background = { color = colors.bg1, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

volume_percent:subscribe("volume_change", function(env)
  local icon = icons.volume._0
  local volume = tonumber(env.INFO)
  sbar.exec("SwitchAudioSource -t output -c", function(result)
    if volume > 60 then
      icon = icons.volume._100
    elseif volume > 30 then
      icon = icons.volume._66
    elseif volume > 10 then
      icon = icons.volume._33
    elseif volume > 0 then
      icon = icons.volume._10
    end

    local lead = ""
    if volume < 10 then
      lead = "0"
    end

    volume_icon:set { icon = icon }
    volume_percent:set { label = lead .. volume .. "%" }
    volume_slider:set { slider = { percentage = volume } }
  end)
end)

local function volume_collapse_details()
  local drawing = volume_bracket:query().popup.drawing == "on"
  if not drawing then
    return
  end
  volume_bracket:set { popup = { drawing = false } }
  sbar.remove "/volume.device\\.*/"
end

local current_audio_device = "None"
local function volume_toggle_details(env)
  if env.BUTTON == "right" then
    sbar.exec "open /System/Library/PreferencePanes/Sound.prefpane"
    return
  end

  local should_draw = volume_bracket:query().popup.drawing == "off"
  if should_draw then
    volume_bracket:set { popup = { drawing = true } }
    sbar.exec("SwitchAudioSource -t output -c", function(result)
      current_audio_device = result:sub(1, -2)
      sbar.exec("SwitchAudioSource -a -t output", function(available)
        local current = current_audio_device
        local color = colors.popup.item
        local counter = 0

        for device in string.gmatch(available, "[^\r\n]+") do
          if current == device then
            color = colors.popup.highlight
          end
          sbar.add("item", "volume.device." .. counter, {
            position = "popup." .. volume_bracket.name,
            width = popup_width,
            align = "center",
            label = { string = device, color = color },
            background = { drawing = false },
            click_script = 'SwitchAudioSource -s "'
              .. device
              .. '" && sketchybar --set /volume.device\\.*/ label.color='
              .. colors.popup.item
              .. " --set $NAME label.color="
              .. colors.popup.highlight,
          })
          counter = counter + 1
        end
      end)
    end)
  else
    volume_collapse_details()
  end
end

local function volume_scroll(env)
  local delta = env.SCROLL_DELTA
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", function(env)
  volume_toggle_details(env)
  -- sbar.animate("tanh", 8, function()
  -- 	volume_icon:set({
  -- 		background = {
  -- 			shadow = {
  -- 				distance = 0,
  -- 			},
  -- 		},
  -- 		y_offset = -4,
  -- 		padding_left = 8,
  -- 		padding_right = 0,
  -- 	})
  -- 	volume_icon:set({
  -- 		background = {
  -- 			shadow = {
  -- 				distance = 4,
  -- 			},
  -- 		},
  -- 		y_offset = 0,
  -- 		padding_left = 4,
  -- 		padding_right = 4,
  -- 	})
  -- end)
end)

volume_icon:subscribe("mouse.scrolled", volume_scroll)
