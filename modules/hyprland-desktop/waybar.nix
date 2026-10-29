{
  config,
  pkgs,
  lib,
  ...
}:
let
  workspaceState = pkgs.writeShellScriptBin "waybar-workspace-state" ''
    exec ${lib.getExe pkgs.python3} ${./waybar-workspace-state.py} "$@"
  '';
in
{
  stylix.targets.waybar.enable = false;

  # One Waybar process per output is controlled by the Hyprland visibility helper.
  home.packages = [
    (pkgs.writeShellScriptBin "waybar-visibility" ''
      exec ${lib.getExe pkgs.python3} ${./waybar-visibility.py} "$@"
    '')
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = false; # Launched by waybar-visibility from Hyprland.
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 44;
      # Match the visible top gap (18 + 6 CSS) to the side gaps (12 + 12 CSS).
      margin-top = 18;
      margin-left = 12;
      margin-right = 12;
      exclusive = false;
      passthrough = false;
      start_hidden = true;
      on-sigusr1 = "hide";
      on-sigusr2 = "show";

      modules-left = [ "group/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "group/status" ];

      # Group the existing right-side modules in one floating island.
      "group/status" = {
        orientation = "horizontal";
        modules = [
          "pulseaudio"
          "custom/voxtype"
          "network"
          "battery"
          "hyprland/language"
          "tray"
        ];
      };

      # Individual workspace slots support independent click commands.
      "group/workspaces" = {
        orientation = "horizontal";
        modules = map (n: "custom/workspace-${toString n}") (lib.range 1 5);
      };

      tray = {
        icon-size = 24;
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

        format-icons = [
          "🪫"
          "🔋"
        ];
      };

      # Voxtype writes its state to $XDG_RUNTIME_DIR/voxtype/state.
      # Follow changes immediately instead of polling once per second.
      "custom/voxtype" = {
        exec = "${lib.getExe config.services.voxtype.package} status --follow --format json --icon-theme text";
        return-type = "json";
        format = "{}";
        tooltip = true;
      };

      "network" = {
        # format-wifi = "  {essid}";
        # format-ethernet = " {ipaddr}/{cidr}";
        format-wifi = "  ";
        format-ethernet = "  ";
        tooltip-format-wifi = "{essid} {frequency} GHz [{signalStrength}%]\n{ipaddr}/{cidr}\n{bandwidthDownBits}/{bandwidthUpBits}";
        tooltip-format-ethernet = "{ipaddr}/{cidr}\n{bandwidthDownBits}/{bandwidthUpBits}";
        format-disconnected = "Offline 🦖";
        min-length = 3;
        max-length = 3;
        interval = 10;
      };
      "pulseaudio" = {
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
          default = [
            "🔈"
            "🔉"
            "🔊"
          ];
        };
        on-click = "pwvucontrol";
        min-length = 8;
      };
    } // builtins.listToAttrs (map (n: {
      name = "custom/workspace-${toString n}";
      value = {
        exec = "${lib.getExe workspaceState} ${toString n}";
        return-type = "json";
        format = "{text}";
        signal = 8;
        tooltip = true;
        # Evaluate the exact same SMW action as the Super+number keybind.
        on-click = "hyprctl eval 'require(\"split_monitor_workspaces\").workspace(\"${toString n}\")()'";
        # Retain the original per-monitor scroll commands.
        on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
        on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
      };
    }) (lib.range 1 5));

    style =
      with config.stylix.fonts;
      with config.lib.stylix.colors;
      ''
        * {
            border: none;
            border-radius: 0;
            font-family: ${sansSerif.name};
            font-size: ${(builtins.toString sizes.terminal) + "px"};
            min-height: 0;
        }

        window#waybar {
            background: transparent;
            color: #${base05};
        }

        /* Solid Stylix base02 islands on a transparent Waybar background. */
        #workspaces, #clock, #status {
            background-color: #${base02};
            border-radius: 8px;
            margin-top: 6px;
            margin-bottom: 6px;
        }

        #workspaces {
            margin-left: 12px;
            padding: 0 8px;
        }

        #clock {
            padding: 0 16px;
        }

        #status {
            margin-right: 12px;
            padding: 0 8px;
        }

        #workspaces .module {
            padding: 2px 5px;
            color: #${base04};
        }

        #workspaces .module.active {
            color: #${base05};
        }

        #workspaces .module.urgent {
            color: #${base08};
        }

        #battery, #pulseaudio, #tray {
            padding-left: 5px;
            padding-right: 5px;
        }

        #custom-voxtype {
          padding-left: 8px;
          padding-right: 8px;
          font-family: ${monospace.name};
          color: #${base04};
        }

        #custom-voxtype.recording {
          color: #${base08};
          background-color: alpha(#${base08}, 0.2);
          font-weight: bold;
          animation-name: voxtype-pulse;
          animation-duration: 0.8s;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        #custom-voxtype.transcribing {
          color: #${base0A};
          font-weight: bold;
        }

        @keyframes voxtype-pulse {
          to {
            opacity: 0.5;
          }
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

        #network.disconnected, #pulseaudio.muted {
            background-color: transparent;
            color: #${base0A};
        }

      '';
  };
}
