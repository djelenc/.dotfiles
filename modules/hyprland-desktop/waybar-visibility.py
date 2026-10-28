#!/usr/bin/env python3
"""Show each Waybar for an empty workspace, Fuzzel, or an ongoing bar interaction.

Waybar is never revealed simply by touching the screen edge. This controller owns
one Waybar process per (non-mirrored) output so an empty workspace on one screen
doesn't make the bar visible on another.
"""

import copy
import json
import os
from pathlib import Path
import select
import signal
import socket
import subprocess
import time

POLL_SECONDS = 0.15
REFRESH_SECONDS = 3.0
BAR_HEIGHT = 26
LEAVE_GRACE_SECONDS = 0.45
STARTUP_GRACE_SECONDS = 1.0

CONFIG_DIR = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "waybar"
RUNTIME_DIR = Path(os.environ["XDG_RUNTIME_DIR"]) / "waybar-visibility"
HYPR_DIR = Path(os.environ["XDG_RUNTIME_DIR"]) / "hypr" / os.environ["HYPRLAND_INSTANCE_SIGNATURE"]


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


def fuzzel_outputs(layers):
    return {
        output for output, info in layers.items()
        if any(
            str(layer.get("namespace", "")).lower().startswith("fuzzel")
            for level in info.get("levels", {}).values()
            for layer in level
        )
    }


def pointer_on_bar(pos, monitor):
    if not isinstance(pos, dict):
        return False
    scale = monitor.get("scale") or 1
    width = monitor["width"] / scale
    return (
        monitor["x"] <= pos.get("x", -1) < monitor["x"] + width
        and monitor["y"] <= pos.get("y", -1) < monitor["y"] + BAR_HEIGHT
    )


class Bar:
    def __init__(self, output, base_config):
        config = copy.deepcopy(base_config)
        config["output"] = output
        config["start_hidden"] = True
        path = RUNTIME_DIR / (output.replace("/", "_") + ".json")
        path.write_text(json.dumps(config))
        self.process = subprocess.Popen(
            ["waybar", "-c", str(path), "-s", str(CONFIG_DIR / "style.css")],
            stdout=subprocess.DEVNULL,
        )
        self.started = time.monotonic()
        self.visible = False
        self.hover_until = 0.0

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
    layers = {}
    next_refresh = 0.0
    dirty = True
    socket_buffer = b""
    events = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    events.connect(str(HYPR_DIR / ".socket2.sock"))
    try:
        while True:
            now = time.monotonic()
            if dirty or now >= next_refresh:
                new_monitors = query("monitors")
                new_clients = query("clients")
                new_layers = query("layers")
                if isinstance(new_monitors, list):
                    monitors = active_outputs(new_monitors)
                if isinstance(new_clients, list):
                    clients = new_clients
                if isinstance(new_layers, dict):
                    layers = new_layers
                dirty = False
                next_refresh = now + REFRESH_SECONDS

            for output in list(bars):
                if output not in monitors or bars[output].process.poll() is not None:
                    bars.pop(output).stop()
            for output in monitors:
                if output not in bars:
                    bars[output] = Bar(output, base_config)

            cursor = query("cursorpos") if any(bar.visible for bar in bars.values()) else None
            launcher_outputs = fuzzel_outputs(layers)
            occupied = {c.get("workspace", {}).get("id") for c in clients}
            for output, monitor in monitors.items():
                bar = bars[output]
                if bar.visible and pointer_on_bar(cursor, monitor):
                    bar.hover_until = now + LEAVE_GRACE_SECONDS
                empty = monitor.get("activeWorkspace", {}).get("id") not in occupied
                show = empty or output in launcher_outputs or (bar.visible and now < bar.hover_until)
                bar.update(show, now)

            ready, _, _ = select.select([events], [], [], POLL_SECONDS)
            if ready:
                chunk = events.recv(65536)
                if not chunk:
                    raise ConnectionError("Hyprland event socket closed")
                socket_buffer += chunk
                *lines, socket_buffer = socket_buffer.split(b"\n")
                if any(
                    line.startswith((b"openwindow>>", b"closewindow>>", b"movewindow>>",
                                     b"fullscreen>>", b"workspace>>", b"workspacev2>>", b"focusedmon>>",
                                     b"moveworkspace>>", b"activespecial>>",
                                     b"monitoradded", b"monitorremoved", b"openlayer>>",
                                     b"closelayer>>", b"movewindowv2>>"))
                    for line in lines
                ):
                    dirty = True
    finally:
        events.close()
        for bar in bars.values():
            bar.stop()


if __name__ == "__main__":
    # Hyprland may stop this launcher during logout or config reload.
    signal.signal(signal.SIGTERM, lambda _sig, _frame: (_ for _ in ()).throw(KeyboardInterrupt))
    try:
        main()
    except KeyboardInterrupt:
        pass
