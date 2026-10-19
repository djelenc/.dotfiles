-- Shared monitor identities used by Hyprland runtime helpers.
--
-- Physical properties such as position, scale and transform stay in config.nix.
-- This module only defines which monitors are part of the regular multi-monitor
-- setup and their fixed logical workspace ranges.

local M = {}

M.source_output = "eDP-1"
M.workspace_count = 5

local workspaces = {
  { identifier = M.source_output, first = 1 },
  { identifier = "desc:AOC Q27P1B GNXL7HA167657", first = 6 },
  { identifier = "desc:Philips Consumer Electronics Company 231PQPY UHB1430018671", first = 11 },
  { identifier = "desc:AOC Q27P1B GNXL7HA167593", first = 6 },
  { identifier = "desc:Dell Inc. DELL U2412M 0FFXD4136Y1L", first = 11 },
}

local function matches_identifier(monitor, identifier)
  if not monitor or not monitor.name then
    return false
  end

  local description = identifier:match("^desc:(.*)$")
  if not description then
    return monitor.name == identifier
  end

  description = description:gsub("^%s+", ""):gsub("%s+$", "")
  local actual = monitor.description or ""

  return description ~= "" and actual:sub(1, #description) == description
end

function M.known_workspace(monitor)
  for _, workspace in ipairs(workspaces) do
    if matches_identifier(monitor, workspace.identifier) then
      return workspace
    end
  end
end

function M.is_known_monitor(monitor)
  return M.known_workspace(monitor) ~= nil
end

-- Fixed ranges for configured displays; other outputs use SMW's defaults.
function M.workspace_range(monitor)
  local known = M.known_workspace(monitor)
  if known then
    return known.first, M.workspace_count, known.identifier
  end
end

-- Shared policy hooks for desktop extensions and the window switcher.
function M.is_work_monitor(monitor)
  return monitor ~= nil and monitor.name ~= nil and not monitor.is_mirror
end

function M.is_work_window(win)
  return win ~= nil and win.mapped and M.is_work_monitor(win.monitor)
end

function M.get_work_monitors()
  local monitors = {}
  for _, monitor in ipairs(hl.get_monitors()) do
    if M.is_work_monitor(monitor) then
      monitors[#monitors + 1] = monitor
    end
  end
  return monitors
end

return M
