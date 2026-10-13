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

-- Super+Tab cycles only the active workspace, committing MRU focus on Super release.
-- Hyprland records each previewed window as focused. Track our own focus history
-- so those intermediate visits do not change which window is next next time.
local mru_windows, mru_index, mru_release_timer
local mru_original_dim = nil
local undim_rules = {}
local active_undim_rules = {}
-- TEMPORARY WORKAROUND: wl-mirror is a normal Wayland window, so exclude it
-- from the custom Super+Tab MRU list. Remove this together with
-- projector-mirror.nix once native Hyprland mirroring supports letterboxing.
local function is_projector_mirror(win)
  return win.title and win.title:match("^hypr%-projector%-mirror:")
end

-- Initialize from Hyprland's existing history; thereafter only completed
-- switches (or ordinary focus changes) alter this ordering.
local focus_order = hl.get_windows()
table.sort(focus_order, function(a, b)
  local ah, bh = a.focus_history_id, b.focus_history_id
  return (ah < 0 and math.huge or ah) < (bh < 0 and math.huge or bh)
end)

local function record_focus(win)
  if not win or not win.mapped or is_projector_mirror(win) then
    return
  end

  for i = #focus_order, 1, -1 do
    if not focus_order[i].mapped or focus_order[i] == win then
      table.remove(focus_order, i)
    end
  end
  table.insert(focus_order, 1, win)
end

-- Ignore focus changes caused by previewing windows within Super+Tab.
hl.on("window.active", function(win)
  if not mru_windows then
    record_focus(win)
  end
end)

local function reset_mru_cycle()
  if mru_windows then
    record_focus(hl.get_active_window())
  end
  mru_windows = nil
  mru_release_timer:set_enabled(false)

  -- Restore global dimming first, then disable the temporary exemptions.
  if mru_original_dim then
    hl.config({ decoration = mru_original_dim })
    mru_original_dim = nil
  end
  for _, rule in ipairs(active_undim_rules) do
    rule:set_enabled(false)
  end
  active_undim_rules = {}
end

-- The global dim_inactive setting would dim windows on all monitors. Temporarily
-- exempt active workspaces on the other monitors using reversible window rules.
-- Cache one rule per workspace rather than accumulating rules on every switch.
local function exempt_workspace_from_dimming(workspace)
  if not workspace then
    return
  end

  local selector = workspace.addressable_name
  local rule = undim_rules[selector]
  if rule then
    rule:set_enabled(true)
  else
    rule = hl.window_rule({
      name = "super-tab-no-dim-" .. selector,
      match = { workspace = selector },
      no_dim = true,
    })
    undim_rules[selector] = rule
  end
  active_undim_rules[#active_undim_rules + 1] = rule
end

local function super_is_down()
  return hl.is_key_down("Super_L") or hl.is_key_down("Super_R")
end

local function begin_mru_cycle()
  local workspace = hl.get_active_workspace()
  if not workspace then
    return
  end

  mru_windows = {}
  for _, win in ipairs(hl.get_workspace_windows(workspace)) do
    if not is_projector_mirror(win) then
      mru_windows[#mru_windows + 1] = win
    end
  end

  local ranks = {}
  for i, win in ipairs(focus_order) do
    if win.mapped then
      ranks[win.address] = i
    end
  end

  table.sort(mru_windows, function(a, b)
    local ar, br = ranks[a.address], ranks[b.address]
    if ar and br then return ar < br end
    if ar then return true end
    if br then return false end
    -- Fallback for windows not yet recorded in our own focus history.
    local ah, bh = a.focus_history_id, b.focus_history_id
    return (ah < 0 and math.huge or ah) < (bh < 0 and math.huge or bh)
  end)

  mru_index = 1

  -- Highlight only the currently selected monitor. Other monitors keep their
  -- normal appearance, even though dim_inactive itself is a global setting.
  if #mru_windows > 1 then
    mru_original_dim = {
      dim_inactive = hl.get_config("decoration.dim_inactive"),
      dim_strength = hl.get_config("decoration.dim_strength"),
    }

    local selected_monitor = hl.get_active_monitor()
    for _, monitor in ipairs(hl.get_monitors()) do
      if monitor ~= selected_monitor then
        exempt_workspace_from_dimming(monitor.active_workspace)
        exempt_workspace_from_dimming(monitor.active_special_workspace)
      end
    end

    hl.config({ decoration = { dim_inactive = true, dim_strength = 0.3 } })
  end

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

-- Toggle offline speech-to-text dictation (start / stop recording).
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("voxtype record toggle"))

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
