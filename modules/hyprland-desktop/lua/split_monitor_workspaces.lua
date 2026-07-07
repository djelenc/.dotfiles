-- GNOME-style linked workspaces across all monitors via split-monitor-workspaces.
-- The package is symlinked to ~/.config/hypr/plugins/split-monitor-workspaces by Home Manager.

package.path = package.path .. ";./?.lua;./?/init.lua"

local smw = require("plugins.split-monitor-workspaces.split-monitor-workspaces")
local globals = require("plugins.split-monitor-workspaces.globals")

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

local function logical_index_for_workspace(workspace)
  if not workspace or workspace.special or not workspace.monitor then
    return nil
  end

  local workspaces = globals.monitor_workspace_map[workspace.monitor.id]
  if not workspaces then
    return nil
  end

  for index, name in ipairs(workspaces) do
    if tostring(name) == tostring(workspace.name) then
      return index
    end
  end

  return nil
end

local function all_monitors_on_logical_index(index)
  for _, monitor in ipairs(hl.get_monitors()) do
    local workspaces = globals.monitor_workspace_map[monitor.id]
    if workspaces and monitor.active_workspace then
      if tostring(monitor.active_workspace.name) ~= tostring(workspaces[index]) then
        return false
      end
    end
  end

  return true
end

-- Waybar's hyprland/workspaces module switches workspaces by dispatching raw
-- Hyprland workspace IDs. That bypasses smw.workspace(...), so linked monitors
-- are not updated. Bridge those raw workspace activations back to the smw API.
hl.on("workspace.active", function(workspace)
  local index = logical_index_for_workspace(workspace)
  if not index or all_monitors_on_logical_index(index) then
    return
  end

  smw.workspace(tostring(index))()
end)

return smw
