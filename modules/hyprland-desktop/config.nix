{
  lib,
  ...
}:
{
  # Static Hyprland options that map cleanly through Home Manager's Lua generator.
  # Dynamic/runtime pieces live in ./lua/*.lua and are loaded through extraLuaFiles.
  wayland.windowManager.hyprland.settings = {
    config = {
      xwayland = {
        force_zero_scaling = true;
      };

      input = {
        kb_layout = "us,si";
        kb_options = "grp:win_space_toggle";
        numlock_by_default = true;

        follow_mouse = 2;
        touchpad = {
          natural_scroll = false;
        };
        sensitivity = 0;
        repeat_rate = 50; # 25
        repeat_delay = 300; # 600
      };

      general = {
        gaps_in = 4;
        gaps_out = 4;
        border_size = 2;
        col = {
          active_border = lib.mkDefault {
            colors = [
              "rgba(33ccffee)"
              "rgba(00ff99ee)"
            ];
            angle = 45;
          };
          inactive_border = lib.mkDefault "rgba(595959aa)";
        };
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = true;
      };

      dwindle = {
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        on_focus_under_fullscreen = 1;
      };
    };

    monitor = [
      # Laptop: below AOC, centered under it.
      # Adjust 512 if it is not visually centered.
      {
        output = "eDP-1";
        mode = "preferred";
        position = "512x1440";
        scale = 1.25;
        vrr = 1;
      }

      # @ Home
      {
        # AOC: main anchor, top-left of layout.
        output = "desc:AOC Q27P1B GNXL7HA167657";
        mode = "preferred";
        position = "0x0";
        scale = 1;
      }

      {
        # Phillips: to the right of AOC, rotated.
        output = "desc:Philips Consumer Electronics Company 231PQPY UHB1430018671";
        mode = "preferred";
        position = "2560x0";
        scale = 1;
        transform = 1;
      }

      # @ FRI
      {
        # AOC: main anchor, top-left of layout.
        output = "desc:AOC Q27P1B GNXL7HA167593";
        mode = "preferred";
        position = "0x0";
        scale = 1;
      }

      {
        # Dell: to the right of AOC, rotated.
        output = "desc:Dell Inc. DELL U2412M 0FFXD4136Y1L";
        mode = "preferred";
        position = "2560x0";
        scale = 1;
        transform = 1;
      }

      # Fallback/mirror
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
        mirror = "eDP-1";
      }
    ];

    env = [
      {
        _args = [
          "GDK_SCALE"
          "1.0"
        ];
      }
      {
        _args = [
          "HYPRCURSOR_SIZE"
          "30"
        ];
      }
      {
        _args = [
          "XCURSOR_SIZE"
          "30"
        ];
      }
    ];
  };
}
