-- Shared monitor identities used by Hyprland runtime helpers.
--
-- Physical properties such as position, scale and transform stay in config.nix.
-- This module only defines which monitors are part of the regular multi-monitor
-- setup and their logical workspace priority.

local M = {}

M.source_output = "eDP-1"

M.monitor_priority = {
  "eDP-1",
  "desc:AOC Q27P1B GNXL7HA167657",
  "desc:Philips Consumer Electronics Company 231PQPY UHB1430018671",
  "desc:AOC Q27P1B GNXL7HA167593",
  "desc:Dell Inc. DELL U2412M 0FFXD4136Y1L",
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

function M.is_known_monitor(monitor)
  for _, identifier in ipairs(M.monitor_priority) do
    if matches_identifier(monitor, identifier) then
      return true
    end
  end

  return false
end

return M
