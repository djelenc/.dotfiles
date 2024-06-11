{ config, inputs, pkgs, lib, ... }:
let
  # converts points to pixels
  ptToPx = pt: builtins.toString (pt * 96 / 72) + "px";
in {

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
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
        all-outputs = true;
        warp-on-scroll = true;
        on-click = "activate";
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
        min-length = 6;
        format = "{capacity}% {icon}";
        format-icons = [ "" "" "" "" "" ];
      };

      "network" = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        format-disconnected = "Disconnected ⚠";
        min-length = 17;
      };
      "pulseaudio" = {
        # scroll-step = 1;
        format = "{volume}% {icon}";
        format-bluetooth = "{volume}% {icon} ";
        format-muted = "";
        format-icons = {
          # headphones = ""; #
          # handsfree = "";
          # headset = "";
          headphones = "🎧";
          handsfree = "🎧";
          headset = "🎧";
          phone = "";
          portable = "";
          car = "";
          default = [ "" "" ];
        };
        on-click = "pavucontrol";
        min-length = 8;
      };

    };

    # example: ${config.lib.stylix.colors.base00}
    style = with config.stylix; ''
      * {
          border: none;
          border-radius: 0;
          font-family: ${fonts.sansSerif.name};
          font-size: ${ptToPx fonts.sizes.desktop};
          min-height: 0;
      }

      window#waybar {
          background: shade(alpha(@borders, 0.2), 1.0);
          color: white;
      }

      #window {
          font-weight: bold;
          font-family: ${fonts.sansSerif.name};
      }

      #workspaces {
          font-family: ${fonts.monospace.name};
      }

      #workspaces button {
          padding: 2px 2px 2px 2px;
          color: white;
      }

      #workspaces button.focused {
          padding: 2px 2px 2px 2px;
          color: #c9545d;
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
        font-family: ${fonts.monospace.name};
        padding-left: 5px;
        padding-right: 5px;
      }

      #clock {
          /* font-weight: bold; */
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
}
