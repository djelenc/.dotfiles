{ inputs, pkgs, lib, ... }: {
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 24;

      modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "battery"
        "hyprland/language"
        "tray"
      ];

      "hyprland/workspaces" = {
        disable-scroll = false;
        format = "{icon}";
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
        all-outputs = true;
        warp-on-scroll = true;
        on-click = "activate";
        format-icons = {
          urgent = "";
          active = ""; # "";
          default = "🞅";
        };
      };

      "hyprland/submap" = { format = ''<span style="italic">{}</span>''; };

      tray = { spacing = 10; };

      "hyprland/language" = {
        format = "{}";
        format-en = " EN ";
        format-sl = " SL ";
        on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
      };

      "clock" = {
        format = "{:%H:%M 󰃭 %d/%m}";
        on-click = "gsimplecal";
      };
      "cpu" = { format = "{usage}% "; };
      "memory" = { format = "{}% "; };
      "battery" = {
        bat = "BAT0";
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}";
        # format-good = ""; # An empty format will hide the module
        # format-full = "";
        format-icons = [ "" "" "" "" "" ];
      };

      "network" = {
        # interface = "wlp2s0"; # (Optional) To force the use of this interface
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        format-disconnected = "Disconnected ⚠";
      };
      "pulseaudio" = {
        # scroll-step = 1;
        format = "{volume}% {icon}";
        format-bluetooth = "{volume}% {icon}";
        format-muted = "";
        format-icons = {
          headphones = "";
          handsfree = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" ];
        };
        on-click = "pavucontrol";
      };

      style = ''
        * {
            border: none;
            border-radius: 0;
            font-family: "Ubuntu Nerd Font";
            font-size: 17px;
            min-height: 0;
        }

        window#waybar {
            background: transparent;
            color: white;
        }

        #window {
            font-weight: bold;
            font-family: "Ubuntu";
        }

        #workspaces button {
            padding: 0 2px;
            background: transparent;
            color: white;
            border-top: 2px solid transparent;
        }

        #workspaces button.focused {
            color: #c9545d;
            border-top: 2px solid #c9545d;
        }

        #mode {
            background: #64727D;
            border-bottom: 2px solid white;
        }

        #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #mode {
            padding-left: 5px;
            padding-right: 5px;
        }

        #language  {
          font-family: monospace;
          padding-left: 5px;
          padding-right: 5px;
        }

        #clock {
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

        #network.disconnected {
            background: #f53c3c;
        }

        #pulseaudio {
        }

        #pulseaudio.muted {
        }

        #tray {
        }
      '';
    };
  };
}
