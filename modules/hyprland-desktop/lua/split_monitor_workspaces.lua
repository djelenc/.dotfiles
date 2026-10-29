package.path = package.path .. ";./?.lua;./?/init.lua"

local smw = require("plugins.split-monitor-workspaces.split-monitor-workspaces")
local helpers = require("plugins.split-monitor-workspaces.helpers")
local monitors = require("plugins.split-monitor-workspaces.monitors")
local monitor_config = require("monitor_config")

-- Apply fixed ranges where configured, retaining SMW's default allocation for
-- other desktop outputs. Native mirrored outputs are skipped by SMW itself.
local monitor_ranges = {}
local calc_base_index = helpers.calc_base_index
helpers.calc_base_index = function(name)
  return monitor_ranges[name] and monitor_ranges[name].first - 1 or calc_base_index(name)
end
local get_monitor_max_ws = helpers.get_monitor_max_ws
helpers.get_monitor_max_ws = function(name)
  return monitor_ranges[name] and monitor_ranges[name].count or get_monitor_max_ws(name)
end

local map_monitor = monitors.map_monitor
monitors.map_monitor = function(monitor)
  if monitor.is_mirror then return map_monitor(monitor) end
  local first, count, identifier = monitor_config.workspace_range(monitor)
  if not first then return map_monitor(monitor) end
  monitor_ranges[monitor.name] = { first = first, count = count }
  local switched = map_monitor(monitor)
  -- Do not let another display on the same connector inherit known workspaces.
  for i = first, first + count - 1 do
    hl.workspace_rule({ workspace = tostring(i), monitor = identifier, persistent = true })
  end
  return switched
end

smw.setup({
  workspace_count = monitor_config.workspace_count,
  keep_focused = true,
  enable_notifications = false,
  enable_persistent_workspaces = true,
  enable_wrapping = true,
  link_monitors = true,
})

-- Waybar's hyprland/workspaces buttons use Hyprland's native workspace
-- dispatcher, not SMW's linked workspace() action. Reconcile a native switch
-- after its workspace.active event so clicking a button on any output selects
-- the same 1-based slot on all outputs. Also handles other native switches.
--
-- Defer the check so SMW's own multi-monitor keybinds can finish switching
-- all monitors before we inspect their state; aligned monitors need no action.
local workspace_sync_pending = nil
local workspace_sync_scheduled = false
local workspace_sync_in_progress = false

local function workspace_slot(workspace)
  if not workspace or workspace.special or type(workspace.id) ~= "number" or workspace.id < 1 then
    return nil
  end
  return ((workspace.id - 1) % smw.get_amount_of_workspaces()) + 1
end

local function reconcile_linked_workspaces()
  workspace_sync_scheduled = false
  local slot = workspace_sync_pending
  workspace_sync_pending = nil
  if not slot then return end

  local count = 0
  local out_of_sync = false
  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor_config.is_work_monitor(monitor) then
      local current = hl.get_active_workspace(monitor)
      local current_slot = workspace_slot(current)
      if current_slot then
        count = count + 1
        if current_slot ~= slot then
          out_of_sync = true
        end
      end
    end
  end

  if count < 2 or not out_of_sync then return end

  workspace_sync_in_progress = true
  local ok, err = pcall(smw.workspace(tostring(slot)))
  workspace_sync_in_progress = false
  if not ok then
    print("[split-monitor-workspaces] Could not reconcile workspace click: " .. tostring(err))
  end
end

hl.on("workspace.active", function(workspace)
  if workspace_sync_in_progress then return end
  local slot = workspace_slot(workspace)
  if not slot then return end

  workspace_sync_pending = slot
  if not workspace_sync_scheduled then
    workspace_sync_scheduled = true
    hl.timer(reconcile_linked_workspaces, { timeout = 35, type = "oneshot" })
  end
end)

-- Layer 1 monitor-disconnect cleanup:
-- move windows from a removed monitor's workspace range back into the
-- corresponding primary-monitor workspace slot. This deliberately does not
-- delete/hide persistent workspaces.
local primary_workspace_count = smw.get_amount_of_workspaces()
local pending_ranges = {}
local flush_scheduled = false

-- In-memory restore map for windows that were alive when an external monitor
-- disappeared and were evacuated to the primary monitor. This intentionally
-- uses Hyprland's stable window id, not app class/title/PID, so a closed and
-- restarted app does not match the old evacuation record.
local evacuated_windows = {}

local function target_workspace_id(source_workspace_id)
  return ((source_workspace_id - 1) % primary_workspace_count) + 1
end

local function source_workspace_range_for_monitor(monitor)
  local workspace = monitor_config.known_workspace(monitor)

  -- The primary monitor owns the first range. Do not evacuate it.
  if not workspace or workspace.first == 1 then
    return nil
  end

  return {
    first = workspace.first,
    last = workspace.first + primary_workspace_count - 1,
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

local function prune_dead_evacuated_windows()
  local live = {}

  for _, win in ipairs(hl.get_windows()) do
    if win.stable_id then
      live[win.stable_id] = true
    end
  end

  for stable_id, _ in pairs(evacuated_windows) do
    if not live[stable_id] then
      evacuated_windows[stable_id] = nil
    end
  end
end

local function flush_pending_evacuations()
  flush_scheduled = false

  if #pending_ranges == 0 then
    return
  end

  prune_dead_evacuated_windows()

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

      if win.stable_id then
        evacuated_windows[win.stable_id] = {
          original_workspace = ws_id,
          evacuation_workspace = target,
        }
      end

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

-- Monitor-connect cleanup:
-- when a new monitor is connected, make it show the workspace that corresponds
-- to the currently visible primary-monitor workspace slot.
--
-- Example:
--   primary on 3, monitor 2 added -> monitor 2 shows 8
--   primary on 3, monitor 3 added -> monitor 3 shows 13
local function get_primary_monitor()
  return hl.get_monitor(monitor_config.source_output)
end

local function workspace_slot_on_primary()
  local primary = get_primary_monitor()
  if not primary then
    return nil
  end

  local ws = hl.get_active_workspace(primary)
  local ws_id = ws and ws.id

  if not ws_id then
    return nil
  end

  -- Only sync from the primary monitor's own workspace range.
  -- In your setup this means 1-5.
  if ws_id < 1 or ws_id > primary_workspace_count then
    return nil
  end

  return ws_id
end

local function sync_monitor_to_primary_slot(monitor)
  local range = source_workspace_range_for_monitor(monitor)

  -- Do not sync the primary monitor to itself.
  if not range then
    return
  end

  local slot = workspace_slot_on_primary()
  if not slot then
    return
  end

  local target_workspace = range.first + slot - 1

  monitor:set_workspace(tostring(target_workspace))

  print(string.format(
    "[split-monitor-workspaces] synced monitor %s to workspace %d",
    monitor.name,
    target_workspace
  ))
end

local function restore_evacuated_windows_for_monitor(monitor)
  local range = source_workspace_range_for_monitor(monitor)
  if not range then
    return
  end

  prune_dead_evacuated_windows()

  local restored = 0
  for _, win in ipairs(hl.get_windows()) do
    local stable_id = win.stable_id
    local record = stable_id and evacuated_windows[stable_id]
    local ws = win.workspace
    local ws_id = ws and ws.id

    if record
        and ws_id == record.evacuation_workspace
        and record.original_workspace >= range.first
        and record.original_workspace <= range.last then
      hl.dispatch(hl.dsp.window.move({
        window = win,
        workspace = tostring(record.original_workspace),
        follow = false,
      }))

      evacuated_windows[stable_id] = nil
      restored = restored + 1
    end
  end

  if restored > 0 then
    print(string.format(
      "[split-monitor-workspaces] restored %d evacuated window(s) to monitor %s",
      restored,
      monitor.name
    ))
  end
end

hl.on("monitor.added", function(monitor)
  if not monitor_config.is_known_monitor(monitor) then
    return
  end
  -- Delay so split-monitor-workspaces can first map the monitor and create/move
  -- its workspace range. This also avoids racing with persistent workspace setup.
  hl.timer(function()
    if not monitor.name or hl.get_monitor(monitor.name) ~= monitor then
      return
    end
    sync_monitor_to_primary_slot(monitor)
    restore_evacuated_windows_for_monitor(monitor)
  end, { timeout = 500, type = "oneshot" })
end)

return smw
