{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 26;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "custom/voxtype"
        "network"
        # "cpu"
        # "memory"
        "battery"
        "hyprland/language"
        "tray"
      ];

      "hyprland/workspaces" = {
        disable-scroll = false;
        format = "{icon}";
        on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
        on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
        all-outputs = false;
        warp-on-scroll = true;
        # on-click = "activate";
        format-icons = {
          urgent = "⧈";
          active = "▣";
          default = "□";
        };
      };

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

        format-icons = [
          "🪫"
          "🔋"
        ];
        # format-icons = [ "" "" "" "" "" ];
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
            background: alpha(#${base04}, 0.25);
            /* background: shade(alpha(#${base04}, 0.2), 1.0); */
            color: #${base05};
        }

        #window {
            font-weight: bold;
        }

        #workspaces {
        }

        #workspaces button {
            padding: 2px 2px 2px 2px;
            color: #${base04};
        }

        #workspaces button.focused {
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
