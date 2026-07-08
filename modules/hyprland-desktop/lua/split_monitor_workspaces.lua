package.path = package.path .. ";./?.lua;./?/init.lua"

local smw = require("plugins.split-monitor-workspaces.split-monitor-workspaces")
local helpers = require("plugins.split-monitor-workspaces.helpers")

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

-- Layer 1 monitor-disconnect cleanup:
-- move windows from a removed monitor's workspace range back into the
-- corresponding primary-monitor workspace slot. This deliberately does not
-- delete/hide persistent workspaces and does not restore windows on reconnect.
local primary_workspace_count = smw.get_amount_of_workspaces()
local pending_ranges = {}
local flush_scheduled = false

local function target_workspace_id(source_workspace_id)
  return ((source_workspace_id - 1) % primary_workspace_count) + 1
end

local function source_workspace_range_for_monitor(monitor)
  if not monitor or not monitor.name then
    return nil
  end

  local base = helpers.calc_base_index(monitor.name)
  local max_ws = helpers.get_monitor_max_ws(monitor.name)

  -- The primary monitor owns the first range. Do not evacuate it.
  if not base or base < primary_workspace_count then
    return nil
  end

  return {
    first = base + 1,
    last = base + max_ws,
  }
end

local function workspace_in_range(workspace_id, range)
  return workspace_id >= range.first and workspace_id <= range.last
end

local function source_range_for_workspace(workspace_id, ranges)
  for _, range in ipairs(ranges) do
    if workspace_in_range(workspace_id, range) then
      return range
    end
  end

  return nil
end

local function flush_pending_evacuations()
  flush_scheduled = false

  if #pending_ranges == 0 then
    return
  end

  local ranges = pending_ranges
  pending_ranges = {}

  local active_ws = hl.get_active_workspace()
  local active_ws_id = active_ws and active_ws.id
  local focus_target = nil

  if active_ws_id and source_range_for_workspace(active_ws_id, ranges) then
    focus_target = target_workspace_id(active_ws_id)
  end

  local moved = 0
  for _, win in ipairs(hl.get_windows()) do
    local ws = win.workspace
    local ws_id = ws and ws.id

    if win.mapped and ws_id and source_range_for_workspace(ws_id, ranges) then
      local target = target_workspace_id(ws_id)
      hl.dispatch(hl.dsp.window.move({ window = win, workspace = tostring(target), follow = false }))
      moved = moved + 1
    end
  end

  if focus_target then
    hl.dispatch(hl.dsp.focus({ workspace = tostring(focus_target) }))
  end

  if moved > 0 then
    print(string.format("[split-monitor-workspaces] evacuated %d window(s) from removed-monitor workspace range(s)", moved))
  end
end

local function schedule_evacuate(range)
  table.insert(pending_ranges, range)

  if flush_scheduled then
    return
  end

  flush_scheduled = true
  hl.timer(flush_pending_evacuations, { timeout = 500, type = "oneshot" })
end

hl.on("monitor.removed", function(monitor)
  local range = source_workspace_range_for_monitor(monitor)
  if not range then
    return
  end

  schedule_evacuate(range)
end)

return smw
