{ config, inputs, pkgs, lib, ... }:
let
  linkedWorkspaces = pkgs.writeShellScriptBin "hyprland-linked-workspace" ''
    ${pkgs.python3}/bin/python3 - "$@" <<'PY'
    import json
    import subprocess
    import sys

    WORKSPACE_COUNT = 5
    PRIORITY = [
        ("name", "eDP-1"),
        ("desc", "AOC Q27P1B GNXL7HA167657"),
        ("desc", "Philips Consumer Electronics Company 231PQPY UHB1430018671"),
        ("desc", "AOC Q27P1B GNXL7HA167593"),
        ("desc", "Dell Inc. DELL U2412M 0FFXD4136Y1L"),
    ]

    def hypr_json(*args):
        return json.loads(subprocess.check_output(["hyprctl", *args, "-j"], text=True))

    def logical_index(workspace_id):
        if workspace_id <= 0:
            return 0
        return ((workspace_id - 1) % WORKSPACE_COUNT) + 1

    def print_status(target):
        try:
            workspace = hypr_json("activeworkspace")
            current = logical_index(int(workspace.get("id", 0)))
        except Exception:
            current = 0

        active = current == target
        print(json.dumps({
            "text": "▣" if active else "□",
            "class": "active" if active else "inactive",
            "tooltip": f"Workspace {target}",
        }))

    def ordered_monitors():
        monitors = hypr_json("monitors")
        used = set()
        ordered = []

        def add(match):
            for monitor in monitors:
                if monitor.get("name") in used:
                    continue
                if match(monitor):
                    ordered.append(monitor)
                    used.add(monitor.get("name"))
                    return

        for kind, value in PRIORITY:
            if kind == "name":
                add(lambda monitor, value=value: monitor.get("name") == value)
            elif kind == "desc":
                add(lambda monitor, value=value: (monitor.get("description") or "").startswith(value))

        for monitor in monitors:
            if monitor.get("name") not in used:
                ordered.append(monitor)
                used.add(monitor.get("name"))

        return ordered

    def switch(target):
        monitors = ordered_monitors()
        focused = next((m.get("name") for m in monitors if m.get("focused")), None)

        commands = []
        for index, monitor in enumerate(monitors):
            workspace_id = index * WORKSPACE_COUNT + target
            commands.append(f"dispatch focusmonitor {monitor['name']}")
            commands.append(f"dispatch workspace {workspace_id}")

        if focused:
            commands.append(f"dispatch focusmonitor {focused}")

        if commands:
            subprocess.run(["hyprctl", "--batch", "; ".join(commands)], check=True)

    def main():
        if len(sys.argv) != 3 or sys.argv[1] not in {"status", "switch"}:
            raise SystemExit("usage: hyprland-linked-workspace {status|switch} N")

        target = int(sys.argv[2])
        if target < 1 or target > WORKSPACE_COUNT:
            raise SystemExit(f"workspace must be between 1 and {WORKSPACE_COUNT}")

        if sys.argv[1] == "status":
            print_status(target)
        else:
            switch(target)

    main()
    PY
  '';

  workspaceModule = n: {
    exec = "${linkedWorkspaces}/bin/hyprland-linked-workspace status ${toString n}";
    return-type = "json";
    interval = 1;
    on-click = "${linkedWorkspaces}/bin/hyprland-linked-workspace switch ${toString n}";
  };
in
{
  stylix.targets.waybar.enable = false;

  home.packages = [ linkedWorkspaces ];

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 26;

      modules-left = [
        "custom/workspace-1"
        "custom/workspace-2"
        "custom/workspace-3"
        "custom/workspace-4"
        "custom/workspace-5"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "network"
        # "cpu"
        # "memory"
        "battery"
        "hyprland/language"
        "tray"
      ];

      "custom/workspace-1" = workspaceModule 1;
      "custom/workspace-2" = workspaceModule 2;
      "custom/workspace-3" = workspaceModule 3;
      "custom/workspace-4" = workspaceModule 4;
      "custom/workspace-5" = workspaceModule 5;

      tray = {
        icon-size = 20;
        spacing = 10;
      };

      "hyprland/language" = {
        format = "{}";
        format-en = "EN";
        format-sl = "SL";
        min-length = 4;
        on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
      };

      "clock" = {
        format = "{:%H:%M 󰃭 %d/%m}";
        on-click = "gsimplecal";
      };

      "battery" = {
        bat = "BAT0";
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        min-length = 7;
        interval = 10;

        # full or not charging
        format = "🔌 {capacity} %";
        tooltip-format = "Full, not charging";

        # on battery
        format-discharging = "{icon} {capacity} %";
        tooltip-format-discharging = "{timeTo}";

        # charging
        format-charging = "⚡ {capacity} %";
        tooltip-format-charging = "{timeTo}";

        # unknown
        format-unknown = "⚠️ Battery";
        tooltip-format-unknown = "Unkown battery status, investigate";

        format-icons = [ "🪫" "🔋" ];
        # format-icons = [ "" "" "" "" "" ];
      };

      "network" = {
        format-wifi = "{bandwidthDownBits}   {bandwidthUpBits}";
        tooltip-format-wifi =
          "{ipaddr} @ {essid} {frequency} GHz [{signalStrength}%]";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        format-disconnected = "Offline 🦖";
        min-length = 23;
        max-length = 23;
        interval = 10;
      };
      "pulseaudio" = {
        # scroll-step = 1;
        format = "{volume} % {icon}";
        format-bluetooth = "{volume} % {icon} ";
        format-muted = "Muted 🔇";
        format-icons = {
          headphones = "🎧";
          handsfree = "🎧";
          headset = "🎧";
          phone = "📞";
          portable = "📞";
          car = "🚗";
          default = [ "🔈" "🔉" "🔊" ];
        };
        on-click = "pwvucontrol";
        min-length = 8;
      };

    };

    style = with config.stylix.fonts;
      with config.lib.stylix.colors; ''
        * {
            border: none;
            border-radius: 0;
            font-family: ${sansSerif.name};
            font-size: ${(builtins.toString sizes.terminal) + "px"};
            min-height: 0;
        }

        window#waybar {
            background: alpha(#${base04}, 0.25);
            /* background: shade(alpha(#${base04}, 0.2), 1.0); */
            color: #${base05};
        }

        #window {
            font-weight: bold;
        }

        #custom-workspace-1,
        #custom-workspace-2,
        #custom-workspace-3,
        #custom-workspace-4,
        #custom-workspace-5 {
            padding: 2px 2px 2px 2px;
            color: #${base04};
        }

        #custom-workspace-1.active,
        #custom-workspace-2.active,
        #custom-workspace-3.active,
        #custom-workspace-4.active,
        #custom-workspace-5.active {
            padding: 2px 2px 2px 2px;
            color: #${base05};
        }

        #mode {
            background: #${base00};
            border-bottom: 2px solid #${base05};
        }

        #clock, #battery, #cpu, #memory, #pulseaudio, #tray, #mode {
            padding-left: 5px;
            padding-right: 5px;
        }

        #language, #network  {
          padding-left: 5px;
          padding-right: 5px;
          font-family: ${monospace.name};
          color: #${base04};
        }

        #clock {
          font-family: ${monospace.name};
          color: #${base04};
          font-weight: bold;
        }

        #battery {
        }

        #battery icon {
            color: red;
        }

        #battery.charging {
        }

        @keyframes blink {
            to {
                background-color: #ffffff;
                color: black;
            }
        }

        #battery.warning:not(.charging) {
            color: white;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #cpu {
        }

        #memory {
        }

        #network {
        }

        #pulseaudio {
        }

        #network.disconnected, #pulseaudio.muted {
            background-color: transparent;
            color: #${base0A};
        }

        #tray {
        }
      '';
  };
}
