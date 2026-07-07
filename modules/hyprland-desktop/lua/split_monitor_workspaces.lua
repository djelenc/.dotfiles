-- GNOME-style linked workspaces across all monitors via split-monitor-workspaces.
-- The package is symlinked to ~/.config/hypr/plugins/split-monitor-workspaces by Home Manager.

package.path = package.path .. ";./?.lua;./?/init.lua"

local smw = require("plugins.split-monitor-workspaces.split-monitor-workspaces")

smw.setup({
  -- Five user-facing workspaces; every monitor receives its own backing range.
  workspace_count = 5,

  -- Keep focus stable across config reloads and keep workspaces alive for Waybar.
  keep_focused = true,
  enable_notifications = false,
  enable_persistent_workspaces = true,
  enable_wrapping = true,

  -- GNOME-style behavior: switching workspace changes all monitors simultaneously.
  link_monitors = true,

  -- The plugin accepts output names and desc: prefixes. Only connected monitors matter.
  -- The first connected AOC becomes the primary workspace range, the side monitor second,
  -- and the laptop panel third when it is part of the layout.
  monitor_priority = {
    -- Laptop
    "eDP-1",

    -- Home
    "desc:AOC Q27P1B GNXL7HA167657",
    "desc:Philips Consumer Electronics Company 231PQPY UHB1430018671",

    -- FRI
    "desc:AOC Q27P1B GNXL7HA167593",
    "desc:Dell Inc. DELL U2412M 0FFXD4136Y1L",
  },
})

return smw
