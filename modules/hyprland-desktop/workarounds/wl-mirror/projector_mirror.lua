-- Loaded only by my.hyprland.wlMirror.enable. All temporary workspace, focus,
-- window-switcher and process policies live here; the base desktop uses native
-- mirroring. Capture the entire eDP-1 output, including workspace changes.

local monitor_config = require("monitor_config")
local source_output = monitor_config.source_output
local mirror_title_prefix = "hypr-projector-mirror:"
local mirrors = {}
local mirror_workspaces = {}
local next_workspace = 20
local active = true

local function is_mirror_monitor(monitor)
  return monitor ~= nil and monitor.name ~= nil and not monitor.is_mirror and not monitor_config.is_known_monitor(monitor)
end

local function is_mirror_window(win)
  local title = win and (win.initial_title or win.title)
  return title ~= nil and title:sub(1, #mirror_title_prefix) == mirror_title_prefix
end

-- Policy is installed before config.reloaded/monitor.added callbacks map any
-- outputs, even though Home Manager loads this module after the key bindings.
local workspace_range = monitor_config.workspace_range
monitor_config.workspace_range = function(monitor)
  if not is_mirror_monitor(monitor) then return workspace_range(monitor) end
  if not mirror_workspaces[monitor.name] then
    mirror_workspaces[monitor.name] = next_workspace
    next_workspace = next_workspace + 1
  end
  return mirror_workspaces[monitor.name], 1, monitor.name
end

local is_work_monitor = monitor_config.is_work_monitor
monitor_config.is_work_monitor = function(monitor)
  return is_work_monitor(monitor) and not is_mirror_monitor(monitor)
end
local is_work_window = monitor_config.is_work_window
monitor_config.is_work_window = function(win)
  return is_work_window(win) and not is_mirror_window(win)
end

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function regex_quote(value)
  return (value:gsub("([\\.^$|?*+()%[%]{}])", "\\%1"))
end

local function stop_command(name)
  local title = regex_quote(mirror_title_prefix .. name)
  return "pkill -f -- " .. shell_quote("(^|/)wl-mirror .*--title " .. title .. " " .. regex_quote(source_output) .. "$") .. " || true"
end

local function return_window(win)
  if not active or not win or not win.mapped or is_mirror_window(win)
      or not is_mirror_monitor(win.monitor) then
    return
  end
  local source = hl.get_monitor(source_output)
  if not source or not source.active_workspace then return end
  local id = win.workspace and win.workspace.id
  local target = id and id >= 1 and id <= 15
    and tostring(((id - 1) % monitor_config.workspace_count) + 1)
    or source.active_workspace.addressable_name
  hl.dispatch(hl.dsp.window.move({ window = win, workspace = target, follow = false }))
end

local function start_mirror(monitor)
  if not active or not is_mirror_monitor(monitor) or mirrors[monitor.name]
      or not hl.get_monitor(source_output) then
    return
  end

  local first = monitor_config.workspace_range(monitor)
  local workspace = tostring(first)
  local title = mirror_title_prefix .. monitor.name
  hl.window_rule({
    name = "projector-mirror-" .. monitor.name,
    match = { initial_title = "^" .. regex_quote(title) .. "$" },
    monitor = monitor.name,
    workspace = workspace .. " silent",
    float = true,
    fullscreen = true,
    no_initial_focus = true,
    no_focus = true,
    no_dim = true,
  })

  -- Clear applications inherited from the former extended-desktop setup.
  for _, win in ipairs(hl.get_windows()) do
    if win.monitor == monitor then return_window(win) end
  end

  -- Restart only this output's mirror on reload. This also replaces an old
  -- fullscreen+pin instance without a separate migration or process supervisor.
  hl.exec_cmd(string.format(
    "%s; exec wl-mirror --fullscreen-output %s --scaling fit --title %s %s",
    stop_command(monitor.name), shell_quote(monitor.name), shell_quote(title), shell_quote(source_output)
  ))
  mirrors[monitor.name] = true
  print(string.format("[monitor-mirror] mirroring %s to %s on workspace %s", source_output, monitor.name, workspace))
end

local function stop_mirror(monitor)
  if monitor and monitor.name and (mirrors[monitor.name] or is_mirror_monitor(monitor)) then
    mirrors[monitor.name] = nil
    hl.exec_cmd(stop_command(monitor.name))
  end
end

local function start_connected_mirrors()
  for _, monitor in ipairs(hl.get_monitors()) do start_mirror(monitor) end
end

hl.on("monitor.added", function(monitor)
  hl.timer(function()
    if monitor.name and hl.get_monitor(monitor.name) == monitor then
      start_connected_mirrors()
    end
  end, { timeout = 500, type = "oneshot" })
end)

hl.on("monitor.removed", function(monitor)
  stop_mirror(monitor)
  if monitor.name == source_output then
    for _, output in ipairs(hl.get_monitors()) do stop_mirror(output) end
  end
end)

hl.on("config.reloaded", function()
  hl.timer(start_connected_mirrors, { timeout = 500, type = "oneshot" })
end)
hl.on("hyprland.start", function()
  hl.timer(start_connected_mirrors, { timeout = 1000, type = "oneshot" })
end)

-- Runs before a reload replaces this Lua state, including when the module is
-- disabled in the new generation. Pending old callbacks must not respawn it.
hl.on("config.unload", function()
  active = false
  for name in pairs(mirrors) do hl.exec_cmd(stop_command(name)) end
end)

-- A projector is a display-only output, not a destination for ordinary windows.
local function guard_window(win)
  if win and is_mirror_monitor(win.monitor) and not is_mirror_window(win) then
    hl.timer(function() return_window(win) end, { timeout = 20, type = "oneshot" })
  end
end
hl.on("window.open", guard_window)
hl.on("window.move_to_workspace", guard_window)
hl.on("monitor.focused", function(monitor)
  if is_mirror_monitor(monitor) then
    hl.timer(function()
      if active and hl.get_active_monitor() == monitor and hl.get_monitor(source_output) then
        hl.dispatch(hl.dsp.focus({ monitor = source_output }))
      end
    end, { timeout = 20, type = "oneshot" })
  end
end)
