#!/usr/bin/env python3
"""Render one clickable Waybar workspace slot for the current output.

The native hyprland/workspaces module hardcodes click dispatches. Five custom
modules instead invoke the same SMW workspace action as Super+1-5.
"""

import json
import os
import subprocess
import sys

SLOTS = 5


def hyprctl_json(command):
    result = subprocess.run(
        ["hyprctl", "-j", command],
        capture_output=True,
        text=True,
        check=True,
        timeout=3,
    )
    return json.loads(result.stdout)


def workspace_state(slot, output):
    monitors = hyprctl_json("monitors")
    monitor = next((item for item in monitors if item.get("name") == output), None)
    if not monitor:
        return {"text": "□", "class": "inactive"}

    active_id = monitor.get("activeWorkspace", {}).get("id")
    if not isinstance(active_id, int) or active_id < 1:
        return {"text": "□", "class": "inactive"}

    # Each monitor has five consecutive workspace IDs (1-5, 6-10, 11-15).
    first_id = active_id - ((active_id - 1) % SLOTS)
    workspace_id = first_id + slot - 1
    active = workspace_id == active_id

    # Preserve the native module's urgent icon when a client needs attention.
    urgent = False
    if not active:
        clients = hyprctl_json("clients")
        urgent = any(
            client.get("urgent", False)
            and client.get("workspace", {}).get("id") == workspace_id
            for client in clients
        )

    if urgent:
        icon, state = "⧈", "urgent"
    elif active:
        icon, state = "▣", "active"
    else:
        icon, state = "□", "inactive"

    return {"text": icon, "class": state, "tooltip": f"Workspace {workspace_id}"}


def main():
    if len(sys.argv) != 2 or not sys.argv[1].isdigit():
        sys.exit("Usage: waybar-workspace-state SLOT (1-5)")
    slot = int(sys.argv[1])
    if not 1 <= slot <= SLOTS:
        sys.exit("Workspace slot must be 1-5")

    try:
        result = workspace_state(slot, os.environ.get("WAYBAR_OUTPUT_NAME"))
    except (OSError, subprocess.SubprocessError, ValueError, TypeError, KeyError):
        result = {"text": "□", "class": "inactive"}

    print(json.dumps(result, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
