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

-- Windows-style MRU cycling across the active workspace on every monitor.
-- Freeze the MRU order while Super is held, so repeated Tab presses walk one
-- stable snapshot instead of immediately bouncing between the two newest windows.
local mru_windows = nil
local mru_index = 0
local mru_release_timer = nil

local function reset_mru_cycle()
  mru_windows = nil
  mru_index = 0

  if mru_release_timer then
    mru_release_timer:set_enabled(false)
  end
end

local function super_is_down()
  return hl.is_key_down("Super_L") or hl.is_key_down("Super_R")
end

local function begin_mru_cycle()
  mru_windows = {}

  -- The workspace-switching layer already keeps each monitor on the linked
  -- workspace (for example 1/6/11, 2/7/12, ...). Collect the currently active
  -- workspace from every connected monitor; no knowledge of that mapping is
  -- needed here.
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.active_workspace then
      for _, win in ipairs(hl.get_workspace_windows(monitor.active_workspace)) do
        table.insert(mru_windows, win)
      end
    end
  end

  table.sort(mru_windows, function(a, b)
    return a.focus_history_id < b.focus_history_id
  end)

  mru_index = 1
  mru_release_timer:set_enabled(true)
end

local function focus_next_mru_window()
  if not mru_windows then
    begin_mru_cycle()
  end

  if not mru_windows or #mru_windows < 2 then
    return
  end

  -- Skip windows that disappeared while the Super-Tab sequence was active.
  for _ = 1, #mru_windows do
    mru_index = (mru_index % #mru_windows) + 1
    local win = mru_windows[mru_index]
    if win.mapped then
      hl.dispatch(hl.dsp.focus({ window = win }))
      return
    end
  end
end

-- A plain Super release binding is a sub-chord of SUPER+Tab and Hyprland can
-- suppress it after the larger chord fires. Poll the actual key state only
-- while an MRU session is active instead, and reset once Super is really up.
mru_release_timer = hl.timer(function()
  if mru_windows and not super_is_down() then
    reset_mru_cycle()
  end
end, { timeout = 20, type = "repeat" })
mru_release_timer:set_enabled(false)

hl.bind(mainMod .. " + Tab", focus_next_mru_window)

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))

-- Zooming.
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("pypr zoom ++0.5"))
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("pypr zoom"))

-- Screenshots.
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))

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
