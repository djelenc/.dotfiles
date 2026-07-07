package.path = package.path .. ";./?.lua;./?/init.lua"

local smw = require("plugins.split-monitor-workspaces.split-monitor-workspaces")

smw.setup({
  workspace_count = 5,
  keep_focused = true,
  enable_notifications = false,
  enable_persistent_workspaces = true,
  enable_wrapping = true,
  link_monitors = true,
  monitor_priority = {
    "eDP-1",
    "desc:AOC Q27P1B GNXL7HA167657",
    "desc:Philips Consumer Electronics Company 231PQPY UHB1430018671",
    "desc:AOC Q27P1B GNXL7HA167593",
    "desc:Dell Inc. DELL U2412M 0FFXD4136Y1L",
  },
})

return smw
