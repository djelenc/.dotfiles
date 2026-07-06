-- Trackpad gestures migrated from the old gesture list.
-- The SUPER split-cycle gestures are intentionally disabled while split-monitor-workspaces is disabled.

hl.gesture({
  fingers = 3,
  direction = "down",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd("hyprland-switch-up"))
  end,
})

hl.gesture({
  fingers = 3,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd("hyprland-switch-down"))
  end,
})

-- Disabled together with split-monitor-workspaces:
--
-- hl.gesture({
--   fingers = 3,
--   direction = "down",
--   mods = "SUPER",
--   action = function()
--     hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch split-cycleworkspaces prev"))
--   end,
-- })
--
-- hl.gesture({
--   fingers = 3,
--   direction = "up",
--   mods = "SUPER",
--   action = function()
--     hl.dispatch(hl.dsp.exec_cmd("hyprctl dispatch split-cycleworkspaces next"))
--   end,
-- })
