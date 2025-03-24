
-- SOURCE : https://alexplescan.com/posts/2024/08/10/wezterm/
-- Config :
--  > win : $HOME\.config\wezterm\wezterm.lua
--  > Lnx : ~/.config/wezterm/wezterm.lua


-- Import the wezterm module
local wezterm = require 'wezterm'
-- Creates a config object which we will be adding our config to
local config = wezterm.config_builder()



-- (This is where our config will go)
--config.color_scheme = 'Tokyo Night'
config.color_scheme = 'Material (base16)'
config.font_size = 12
config.initial_cols = 100
config_initial_rows = 24
config.default_prog = { 'pwsh.exe' }
--config.default_prog = { 'wsl.exe' }

-- Removes the title bar, leaving only the tab bar. Keeps
-- the ability to resize by dragging the window's edges.
-- 'RESIZE|INTEGRATED_BUTTONS' also looks nice if
-- you want to keep the window controls visible and integrate
-- them into the tab bar.
config.window_decorations = 'INTEGRATED_BUTTONS'
-- Sets the font for the window frame (tab bar)
config.window_frame = {
  font_size = 12,
}

config.window_background_gradient = {
  colors = { '#364A5F', '#D13ABD' },
  -- Specifices a Linear gradient starting in the top left corner.
  orientation = { Linear = { angle = -45.0 } },
}

local function segments_for_right_status(window)
  return {
    --window:active_workspace(),
    wezterm.strftime('%d/%m - %H:%M'),
    --wezterm.hostname(),
  }
end

wezterm.on('update-status', function(window)
  -- Grab the utf8 character for the "powerline" left facing
  -- solid arrow.
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local segments = segments_for_right_status(window)

  -- Grab the current window's configuration, and from it the
  -- palette (this is the combination of your chosen colour scheme
  -- including any overrides).
  local color_scheme = window:effective_config().resolved_palette
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground
  local gradient_to, gradient_from = bg
  gradient_from = gradient_to:lighten(0.2)
  
  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )
  
  -- We'll build up the elements to send to wezterm.format in this table.
local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)



-- Returns our config to be evaluated. We must always do this at the bottom of this file
return config
