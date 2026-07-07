-- Trackpad gestures for linked split-monitor-workspaces.

local smw = require("split_monitor_workspaces")

hl.gesture({
  fingers = 3,
  direction = "down",
  action = smw.cycle_workspaces("prev"),
})

hl.gesture({
  fingers = 3,
  direction = "up",
  action = smw.cycle_workspaces("next"),
})

hl.gesture({
  fingers = 3,
  direction = "down",
  mods = "SUPER",
  action = smw.cycle_workspaces("prev"),
})

hl.gesture({
  fingers = 3,
  direction = "up",
  mods = "SUPER",
  action = smw.cycle_workspaces("next"),
})
