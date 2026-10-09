-- Mirror temporary/unknown external displays with wl-mirror instead of
-- Hyprland's native monitor mirroring. This preserves the source aspect ratio
-- and produces real black letterboxing/pillarboxing where needed.

local monitor_config = require("monitor_config")
local source_output = monitor_config.source_output
local mirror_title_prefix = "hypr-projector-mirror:"

local mirrors = {}

local function is_unknown_external(monitor)
  if not monitor or not monitor.name or monitor.name == source_output then
    return false
  end

  return not monitor_config.is_known_monitor(monitor)
end

local function start_mirror(monitor)
  if not is_unknown_external(monitor) or mirrors[monitor.name] then
    return
  end

  mirrors[monitor.name] = true

  local title = mirror_title_prefix .. monitor.name
  local cmd = string.format(
    "wl-mirror --fullscreen-output %s --scaling fit --title %s %s",
    monitor.name,
    title,
    source_output
  )

  print(string.format(
    "[monitor-mirror] mirroring %s to unknown output %s (%s)",
    source_output,
    monitor.name,
    monitor.description or "no description"
  ))

  hl.exec_cmd(cmd)
end

local function stop_mirror(monitor)
  if not monitor or not monitor.name or not mirrors[monitor.name] then
    return
  end

  mirrors[monitor.name] = nil

  -- Match only the wl-mirror instance targeting this connector.
  hl.exec_cmd(string.format(
    [[pkill -f "wl-mirror .*--fullscreen-output %s .*%s" || true]],
    monitor.name,
    source_output
  ))
end

hl.on("monitor.added", function(monitor)
  -- Let Hyprland finish applying the monitor rule before asking wl-mirror to
  -- fullscreen on the newly connected output.
  hl.timer(function()
    start_mirror(monitor)
  end, { timeout = 500, type = "oneshot" })
end)

hl.on("monitor.removed", function(monitor)
  stop_mirror(monitor)
end)

-- Covers an unknown display that is already connected when Hyprland starts.
hl.on("hyprland.start", function()
  hl.timer(function()
    for _, monitor in ipairs(hl.get_monitors()) do
      start_mirror(monitor)
    end
  end, { timeout = 1000, type = "oneshot" })
end)

-- Keep the mirror visible across linked workspace switches without letting it
-- steal focus when it appears.
hl.window_rule({
  name = "projector-mirror",
  match = { initial_title = "^hypr-projector-mirror:.*$" },
  float = true,
  pin = true,
  fullscreen = true,
  no_initial_focus = true,
})
