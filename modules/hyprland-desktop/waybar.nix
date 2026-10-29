{
  config,
  pkgs,
  lib,
  ...
}:
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
      # Offset the whole Waybar layer from the screen edges.
      margin-top = 10;
      margin-left = 12;
      margin-right = 12;
      exclusive = false;
      passthrough = false;
      start_hidden = true;
      on-sigusr1 = "hide";
      on-sigusr2 = "show";

      modules-left = [ "hyprland/workspaces" ];
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

      "hyprland/workspaces" = {
        disable-scroll = false;
        format = "{icon}";
        on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
        on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
        all-outputs = false;
        warp-on-scroll = true;
        format-icons = {
          urgent = "⧈";
          active = "▣";
          default = "□";
        };
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
        format-wifi = "{bandwidthDownBits}   {bandwidthUpBits}";
        tooltip-format-wifi = "{ipaddr} @ {essid} {frequency} GHz [{signalStrength}%]";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        format-disconnected = "Offline 🦖";
        min-length = 23;
        max-length = 23;
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
    };

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

        #workspaces button {
            padding: 2px 5px;
            color: #${base04};
        }

        #workspaces button.active {
            color: #${base05};
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
