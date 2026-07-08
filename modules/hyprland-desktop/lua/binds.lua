-- Key and mouse bindings migrated from the old hyprlang bind lists.

local mainMod = "SUPER"
local smw = require("split_monitor_workspaces")

local function move_to_linked_workspace(relative)
  return function()
    local win = hl.get_active_window()
    if not win then
      return
    end

    -- Avoid smw.move_to_workspace("+/-1") with link_monitors=true: that follows
    -- the moved window first and then resolves the relative target once more on
    -- the now-changed active monitor. A silent move followed by one linked cycle
    -- preserves the intended old behavior.
    smw.move_to_workspace_silent(relative)()

    if relative:sub(1, 1) == "-" then
      smw.cycle_workspaces("prev")()
    else
      smw.cycle_workspaces("next")()
    end

    -- Restore focus to the window we moved.
    if win.mapped then
      hl.dispatch(hl.dsp.focus({ window = win }))
    end
  end
end

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("alacritty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + G", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + O", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Scratchpad.
hl.bind(mainMod .. " + grave", hl.dsp.workspace.toggle_special("scratch"))

-- Drop from scratch to the active workspace.
hl.bind(
  mainMod .. " + SHIFT + grave",
  hl.dsp.exec_cmd([[hyprctl dispatch movetoworkspace "$(hyprctl activeworkspace -j | jq -r '.id')"]])
)

-- Change keyboard layout.
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout at-translated-set-2-keyboard next"))

-- GNOME-style linked workspace navigation across all monitors.
hl.bind(mainMod .. " + CONTROL + j", smw.cycle_workspaces("next"))
hl.bind(mainMod .. " + CONTROL + k", smw.cycle_workspaces("prev"))

-- Move active window to the next/previous linked workspace and follow it.
hl.bind(mainMod .. " + SHIFT + j", move_to_linked_workspace("+1"))
hl.bind(mainMod .. " + SHIFT + k", move_to_linked_workspace("-1"))

-- Move windows between adjacent tiled positions / monitors.
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))

-- Move active window to next/previous monitor.
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.window.move({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.move({ monitor = "-1" }))

-- Direct workspace selection. Because link_monitors is enabled, every monitor switches to
-- the corresponding workspace in its own monitor-specific range.
for i = 1, smw.get_amount_of_workspaces() do
  local n = tostring(i)
  if n == "10" then n = "0" end
  hl.bind(mainMod .. " + " .. n, smw.workspace(n))
  hl.bind(mainMod .. " + SHIFT + " .. n, smw.move_to_workspace(n))
end

-- TODO: should be MRU and include apps on all monitors.
hl.bind(mainMod .. " + Tab", function()
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.bring_to_top())
end)

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))

-- Zooming.
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("pypr zoom ++0.5"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("pypr zoom"))

-- Repeat while held.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { repeating = true })

-- Mouse bindings.
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Lock on lid-open.
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprlock"), { locked = true })

-- Execute on release.
hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd("pkill fuzzel || fuzzel"), { release = true })
