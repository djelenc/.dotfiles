{
  lib,
  pkgs,
  ...
}:
let
  # switch one workspace down on all monitors
  hyprland-switch-down = pkgs.writeShellScriptBin "hyprland-switch-down" ''
    num_monitors=$(hyprctl monitors | grep -c "ID")

    cmds=""
    for ((i = 1; i <= num_monitors; i++)); do
        cmds+="dispatch split-cycleworkspaces next; dispatch focusmonitor +1; "
    done

    hyprctl --batch "$cmds"
  '';
  # switch one workspace up on all monitors
  hyprland-switch-up = pkgs.writeShellScriptBin "hyprland-switch-up" ''
    num_monitors=$(hyprctl monitors | grep -c "ID")

    cmds=""
    for ((i = 1; i <= num_monitors; i++)); do
        cmds+="dispatch split-cycleworkspaces prev; dispatch focusmonitor +1; "
    done

    hyprctl --batch "$cmds"
  '';
  # move window one workespace down and switch all workspace one down
  hyprland-move-down = pkgs.writeShellScriptBin "hyprland-move-down" ''
    num_monitors=$(hyprctl monitors | grep -c "ID")

    # move
    cmds="dispatch split-movetoworkspacesilent +1; "

    # switch
    for ((i = 1; i <= num_monitors; i++)); do
        cmds+="dispatch split-cycleworkspaces next; dispatch focusmonitor +1; "
    done

    hyprctl --batch "$cmds"
  '';
  # move window one workespace up and switch all workspace one up
  hyprland-move-up = pkgs.writeShellScriptBin "hyprland-move-up" ''
    num_monitors=$(hyprctl monitors | grep -c "ID")

    # move
    cmds="dispatch split-movetoworkspacesilent -1; "

    # switch
    for ((i = 1; i <= num_monitors; i++)); do
        cmds+="dispatch split-cycleworkspaces prev; dispatch focusmonitor +1; "
    done

    hyprctl --batch "$cmds"
  '';
in
{
  home.packages = [
    hyprland-switch-down
    hyprland-switch-up
    hyprland-move-down
    hyprland-move-up
  ];

  # Static Hyprland options that map cleanly through Home Manager's Lua generator.
  # Dynamic/runtime pieces live in ./lua/*.lua and are loaded through extraLuaFiles.
  wayland.windowManager.hyprland.settings = {
    config = {
      xwayland = {
        force_zero_scaling = true;
      };

      # Workaround for missing cursors on other monitors
      cursor = {
        no_hardware_cursors = true;
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

      # AOC: main anchor, top-left of layout.
      {
        output = "desc:AOC Q27P1B GNXL7HA167593";
        mode = "preferred";
        position = "0x0";
        scale = 1;
      }

      # Dell: to the right of AOC, rotated.
      {
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
