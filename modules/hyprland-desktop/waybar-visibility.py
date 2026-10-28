#!/usr/bin/env python3
"""Show each Waybar for an empty workspace, Fuzzel, or an ongoing bar interaction.

Waybar is never revealed simply by touching the screen edge. This controller owns
one Waybar process per (non-mirrored) output so an empty workspace on one screen
doesn't make the bar visible on another.
"""

import copy
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
LAYER_REFRESH_SECONDS = 0.2  # Fuzzel may not emit a reliable layer-open event.
BAR_HEIGHT = 26
LEAVE_GRACE_SECONDS = 0.45
STARTUP_GRACE_SECONDS = 1.0
WORKSPACE_REVEAL_SECONDS = 1.0
LAUNCHER_REVEAL_GRACE_SECONDS = 1.0

CONFIG_DIR = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "waybar"
RUNTIME_DIR = Path(os.environ["XDG_RUNTIME_DIR"]) / "waybar-visibility"
CONTROL_SOCKET = RUNTIME_DIR / "control.sock"
HYPR_DIR = Path(os.environ["XDG_RUNTIME_DIR"]) / "hypr" / os.environ["HYPRLAND_INSTANCE_SIGNATURE"]


def request_launcher_reveal():
    """Notify the already-running controller before starting Fuzzel."""
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as client:
            client.sendto(b"launcher", str(CONTROL_SOCKET))
    except OSError:
        # Waybar is optional: a missing controller must never block the launcher.
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


def fuzzel_outputs(layers):
    return {
        output for output, info in layers.items()
        if any(
            str(layer.get("namespace", "")).lower() in ("fuzzel", "launcher")
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
    next_layer_refresh = 0.0
    workspace_reveal_until = 0.0
    launcher_reveal_until = 0.0
    launcher_reveal_output = None
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

            # Layer events are not guaranteed to arrive for short-lived launchers.
            # Refresh them independently so opening Fuzzel reveals Waybar quickly.
            if now >= next_layer_refresh:
                new_layers = query("layers")
                if isinstance(new_layers, dict):
                    layers = new_layers
                next_layer_refresh = now + LAYER_REFRESH_SECONDS

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
                show = (
                    empty
                    or now < workspace_reveal_until
                    or output in launcher_outputs
                    or (output == launcher_reveal_output and now < launcher_reveal_until)
                    or (bar.visible and now < bar.hover_until)
                )
                bar.update(show, now)

            ready, _, _ = select.select([events, control], [], [], POLL_SECONDS)
            if control in ready and control.recv(128) == b"launcher":
                # The Super shortcut asks for visibility before Fuzzel maps its layer.
                # Once Fuzzel maps, ordinary layer tracking takes over.
                target = next(
                    (name for name, monitor in monitors.items() if monitor.get("focused")),
                    None,
                )
                if target is not None:
                    launcher_reveal_output = target
                    launcher_reveal_until = time.monotonic() + LAUNCHER_REVEAL_GRACE_SECONDS

            if events in ready:
                chunk = events.recv(65536)
                if not chunk:
                    raise ConnectionError("Hyprland event socket closed")
                socket_buffer += chunk
                *lines, socket_buffer = socket_buffer.split(b"\n")
                if any(line.startswith((b"workspace>>", b"workspacev2>>")) for line in lines):
                    # Repeated workspace events just extend the common one-second reveal.
                    # A focusedmon event alone must NOT reveal all bars when the pointer
                    # moves between monitors.
                    workspace_reveal_until = time.monotonic() + WORKSPACE_REVEAL_SECONDS
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
        control.close()
        CONTROL_SOCKET.unlink(missing_ok=True)
        for bar in bars.values():
            bar.stop()


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--reveal-launcher":
        request_launcher_reveal()
        sys.exit(0)
    if len(sys.argv) != 1:
        sys.exit("usage: waybar-visibility [--reveal-launcher]")
    # Hyprland may stop this launcher during logout or config reload.
    signal.signal(signal.SIGTERM, lambda _sig, _frame: (_ for _ in ()).throw(KeyboardInterrupt))
    try:
        main()
    except KeyboardInterrupt:
        pass
