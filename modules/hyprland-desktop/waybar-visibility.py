#!/usr/bin/env python3
"""Show Waybar on each empty workspace or globally during a hold, launcher or hover.

Touching the screen edge alone never reveals a hidden bar. Each non-mirrored
output has a persistent Waybar process; only the empty-workspace rule is local.
"""

import json
import os
import sys
from pathlib import Path
import select
import signal
import socket
import subprocess
import time

POLL_SECONDS = 0.15
REFRESH_SECONDS = 3.0
LEAVE_GRACE_SECONDS = 0.45
STARTUP_GRACE_SECONDS = 1.0

CONFIG_DIR = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "waybar"
RUNTIME_DIR = Path(os.environ["XDG_RUNTIME_DIR"]) / "waybar-visibility"
CONTROL_SOCKET = RUNTIME_DIR / "control.sock"
HYPR_DIR = Path(os.environ["XDG_RUNTIME_DIR"]) / "hypr" / os.environ["HYPRLAND_INSTANCE_SIGNATURE"]


def notify_controller(command):
    """Send visibility events to the controller without blocking the caller."""
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as client:
            client.sendto(command.encode(), str(CONTROL_SOCKET))
    except OSError:
        # Shortcut actions must still work if the controller is unavailable.
        pass


def query(command):
    try:
        completed = subprocess.run(
            ["hyprctl", "-j", command], capture_output=True, text=True,
            timeout=2, check=True,
        )
        return json.loads(completed.stdout)
    except (subprocess.SubprocessError, OSError, json.JSONDecodeError):
        return None


def active_outputs(monitors):
    return {
        m["name"]: m for m in monitors
        if m.get("name") and m.get("mirrorOf") in (None, "", "none")
    }


def pointer_on_bar(pos, monitor, bar_config):
    if not isinstance(pos, dict):
        return False
    scale = monitor.get("scale") or 1
    width = monitor["width"] / scale
    left = monitor["x"] + bar_config.get("margin-left", 0)
    top = monitor["y"] + bar_config.get("margin-top", 0)
    right = monitor["x"] + width - bar_config.get("margin-right", 0)
    return (
        left <= pos.get("x", -1) < right
        and top <= pos.get("y", -1) < top + bar_config["height"]
    )


class Bar:
    def __init__(self, output, base_config):
        config = dict(base_config)
        config["output"] = output
        path = RUNTIME_DIR / (output.replace("/", "_") + ".json")
        path.write_text(json.dumps(config))
        self.process = subprocess.Popen(
            ["waybar", "-c", str(path), "-s", str(CONFIG_DIR / "style.css")],
            stdout=subprocess.DEVNULL,
        )
        self.started = time.monotonic()
        self.visible = False

    def update(self, show, now):
        if now - self.started < STARTUP_GRACE_SECONDS or show == self.visible:
            return
        try:
            self.process.send_signal(signal.SIGUSR2 if show else signal.SIGUSR1)
            self.visible = show
        except ProcessLookupError:
            pass

    def stop(self):
        if self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait()


def main():
    RUNTIME_DIR.mkdir(mode=0o700, parents=True, exist_ok=True)
    source = json.loads((CONFIG_DIR / "config").read_text())
    # Home Manager emits a list even when settings.mainBar is the only bar.
    if not isinstance(source, list) or len(source) != 1:
        raise RuntimeError("Expected exactly one Home Manager Waybar configuration")
    base_config = source[0]

    bars = {}
    monitors = {}
    clients = []
    next_refresh = 0.0
    workspace_hold = False
    launcher_open = False
    hover_until = 0.0
    dirty = True
    socket_buffer = b""
    events = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    control = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    # Clean up a socket left by a previously stopped controller.
    CONTROL_SOCKET.unlink(missing_ok=True)
    control.bind(str(CONTROL_SOCKET))
    try:
        events.connect(str(HYPR_DIR / ".socket2.sock"))
        while True:
            now = time.monotonic()
            if dirty or now >= next_refresh:
                new_monitors = query("monitors")
                new_clients = query("clients")
                if isinstance(new_monitors, list):
                    monitors = active_outputs(new_monitors)
                if isinstance(new_clients, list):
                    clients = new_clients
                dirty = False
                next_refresh = now + REFRESH_SECONDS

            for output in list(bars):
                if output not in monitors or bars[output].process.poll() is not None:
                    bars.pop(output).stop()
            for output in monitors:
                if output not in bars:
                    bars[output] = Bar(output, base_config)

            # Hovering any already-visible Waybar reveals all Waybars, including
            # those on occupied workspaces. Keep the reveal briefly after leaving.
            # A hidden Waybar cannot be shown just by moving to the screen edge.
            cursor = query("cursorpos") if any(bar.visible for bar in bars.values()) else None
            if any(
                bars[output].visible and pointer_on_bar(cursor, monitor, base_config)
                for output, monitor in monitors.items()
            ):
                hover_until = now + LEAVE_GRACE_SECONDS

            occupied = {c.get("workspace", {}).get("id") for c in clients}
            reveal_all = workspace_hold or launcher_open or now < hover_until
            for output, monitor in monitors.items():
                empty = monitor.get("activeWorkspace", {}).get("id") not in occupied
                bars[output].update(empty or reveal_all, now)

            ready, _, _ = select.select([events, control], [], [], POLL_SECONDS)
            if control in ready:
                message = control.recv(128)
                if message == b"launcher-open":
                    launcher_open = True
                elif message == b"launcher-close":
                    launcher_open = False
                elif message == b"workspace-hold-start":
                    workspace_hold = True
                elif message == b"workspace-hold-end":
                    workspace_hold = False

            if events in ready:
                chunk = events.recv(65536)
                if not chunk:
                    raise ConnectionError("Hyprland event socket closed")
                socket_buffer += chunk
                *lines, socket_buffer = socket_buffer.split(b"\n")
                if any(
                    line.startswith((b"openwindow>>", b"closewindow>>", b"movewindow>>",
                                     b"workspace>>", b"workspacev2>>", b"focusedmon>>",
                                     b"moveworkspace>>", b"activespecial>>",
                                     b"monitoradded", b"monitorremoved", b"movewindowv2>>"))
                    for line in lines
                ):
                    dirty = True
    finally:
        events.close()
        control.close()
        CONTROL_SOCKET.unlink(missing_ok=True)
        for bar in bars.values():
            bar.stop()


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] in (
        "launcher-open", "launcher-close",
        "workspace-hold-start", "workspace-hold-end",
    ):
        notify_controller(sys.argv[1])
        sys.exit(0)
    if len(sys.argv) != 1:
        sys.exit("usage: waybar-visibility [launcher-open|launcher-close|workspace-hold-start|workspace-hold-end]")
    # Hyprland may stop this launcher during logout or config reload.
    signal.signal(signal.SIGTERM, lambda _sig, _frame: (_ for _ in ()).throw(KeyboardInterrupt))
    try:
        main()
    except KeyboardInterrupt:
        pass
