{ config, lib, pkgs, inputs, ... }:
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
in {
  # hyprland config
  wayland.windowManager.hyprland.settings = {
    xwayland = { force_zero_scaling = true; };

    exec-once = [
      "${pkgs.waybar}/bin/waybar"
      "${pkgs.wlsunset}/bin/wlsunset -l 46 -L 14.5"
      "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
      "${pkgs.blueman}/bin/blueman-applet"
      "${pkgs.nextcloud-client}/bin/nextcloud"
      "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch cliphist store # Stores only text data"
      "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store # Stores only image data"
      "${inputs.pyprland.packages.${pkgs.system}.pyprland}/bin/pypr"
    ];

    monitor = [
      # name, resolution, position, scale
      "eDP-1, preferred, auto, 1.25, vrr, 1"
      "desc:AOC Q27P1B GNXL7HA167657, preferred, auto-center-up, 1"
      "desc:Philips Consumer Electronics Company 231PQPY UHB1430018671, preferred, auto-center-right, 1, transform, 1"
      "desc:AOC Q27P1B GNXL7HA167593, preferred, auto-center-left, 1"
      "desc:Dell Inc. DELL U2412M 0FFXD4136Y1L, preferred, auto-center-right, 1, transform, 1"
      # Philips Consumer Electronics Company 231PQPY UHB1430018671
      ", preferred, auto, 1, mirror, eDP-1"
      # Deciding which screens are turned on/off is done with kanshi
    ];

    env = [
      # "GDK_SCALE,1.25"
      "GDK_SCALE,1.0"
      "HYPRCURSOR_SIZE,30"
      "XCURSOR_SIZE,30"
    ];

    input = {
      kb_layout = "us,si";
      kb_options = "grp:win_space_toggle";
      numlock_by_default = true;

      follow_mouse = 2;
      touchpad = { natural_scroll = "no"; };
      sensitivity = 0;
      repeat_rate = 50; # 25
      repeat_delay = 300; # 600
    };

    general = {
      gaps_in = 4;
      gaps_out = 4;
      border_size = 2;
      "col.active_border" = lib.mkDefault "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = lib.mkDefault "rgba(595959aa)";
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
      enabled = "yes";
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 2, default, slidevert"
      ];
    };

    dwindle = {
      pseudotile = "yes";
      preserve_split = "yes";
    };

    # hyprctl dispatch split-cycleworkspaces next
    gesture = [
      "3, down, dispatcher, exec, ${hyprland-switch-up}/bin/hyprland-switch-up"
      "3, up, dispatcher, exec, ${hyprland-switch-down}/bin/hyprland-switch-down"
      "3, down, mod:SUPER, dispatcher, split-cycleworkspaces, prev"
      "3, up, mod:SUPER, dispatcher, split-cycleworkspaces, next"
    ];

    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
      on_focus_under_fullscreen = 1;
    };

    "$mainMod" = "SUPER";

    bind = [
      "$mainMod, T, exec, alacritty"
      "$mainMod, Q, killactive,"
      "$mainMod, M, fullscreen, 1"
      "$mainMod SHIFT, Q, exit,"
      "$mainMod, F, exec, nautilus"
      "$mainMod, G, togglefloating,"
      "$mainMod, O, togglesplit,"
      "$mainMod, h, movefocus, l"
      "$mainMod, l, movefocus, r"
      "$mainMod, k, movefocus, u"
      "$mainMod, j, movefocus, d"

      # scratchpad
      "$mainMod, grave, togglespecialworkspace, scratch"
      # drop from scratch to active workspace
      ''
        $mainMod SHIFT, grave, exec, hyprctl dispatch movetoworkspace "$(hyprctl activeworkspace -j | jq -r '.id')"
      ''

      # change keyboard
      "$mainMod, SPACE, exec, hyprctl switchxkblayout at-translated-set-2-keyboard next"

      # configuration: monitors side-by-side, workspaces switch up/down
      "$mainMod CONTROL, j, exec, ${hyprland-switch-down}/bin/hyprland-switch-down"
      "$mainMod CONTROL, k, exec, ${hyprland-switch-up}/bin/hyprland-switch-up"
      "$mainMod SHIFT, j, exec, ${hyprland-move-down}/bin/hyprland-move-down"
      "$mainMod SHIFT, k, exec, ${hyprland-move-up}/bin/hyprland-move-up"
      "$mainMod SHIFT, h, movewindow, l"
      "$mainMod SHIFT, l, movewindow, r"
      "$mainMod SHIFT, n, split-changemonitor, next"
      "$mainMod SHIFT, p, split-changemonitor, prev"

      # TODO: should be MRU not cycling
      # TODO: should include apps on all monitors
      # "$mainMod, Tab, cyclenext, visible hist" # <-- problem, ko je okno maksimizirano
      "$mainMod, Tab, cyclenext, "
      "$mainMod, Tab, alterzorder, top"

      ", xf86audiomute, exec, swayosd-client --output-volume mute-toggle"
      ", xf86audiomicmute, exec, swayosd-client --input-volume mute-toggle"
      "$mainMod, escape, exec, hyprlock"

      # zooming
      "$mainMod, Z, exec, pypr zoom ++0.5"
      "$mainMod SHIFT, Z, exec, pypr zoom"
    ];

    # when held, repeat key
    binde = [
      ", xf86audioraisevolume, exec, swayosd-client --output-volume raise"
      ", xf86audiolowervolume, exec, swayosd-client --output-volume lower"
      ", xf86monbrightnessup, exec, swayosd-client --brightness raise"
      ", xf86monbrightnessdown, exec, swayosd-client --brightness lower"
    ];

    bindm =
      [ "$mainMod, mouse:272, movewindow" "$mainMod, mouse:273, resizewindow" ];

    # lock on lid-open
    bindl = [ ",switch:off:Lid Switch, exec, hyprlock" ];

    # execute on release
    bindr = "$mainMod, SUPER_L, exec, pkill fuzzel || fuzzel";

    # TO-REMOVE: Old rules, check if new work OK, delete then
    # windowrulev2 = [
    #   "float,class:^(com.saivert.pwvucontrol)$"
    #   "float,class:^(com.nextcloud.desktopclient.nextcloud)$"
    #   "float,class:(blueman)"
    #   "float,class:^(vlc)$"
    #   "float,class:^(org.keepassxc.KeePassXC)$"
    #   "float,initialTitle:(All Files)"
    #   "float,initialTitle:.*wants to save$"
    #   "float,initialTitle:^(Print)$"
    #   "move 45% 2.9%,class:^(gsimplecal)$"
    #   "float,initialTitle:.*Welcome to PyCharm"
    #   "float, title:^Calc$" # calc always floats
    # ];

    # To be used when upgrading
    windowrule = [
      "float on, match:class ^(com.saivert.pwvucontrol)$"
      "float on, match:class ^(com.nextcloud.desktopclient.nextcloud)$"
      "float on, match:class blueman"
      "float on, match:class ^(vlc)$"
      "float on, match:class ^(org.keepassxc.KeePassXC)$"

      # dialogs (titles often contain spaces; that's fine as a regex)
      "float on, match:initial_title (All Files)"
      "float on, match:initial_title .*wants to save$"
      "float on, match:initial_title ^(Print)$"
      "float on, match:initial_title .*Welcome to PyCharm"

      # gsimplecal: old "move 45% 2.9%" often breaks with the new expression parser.
      # Use monitor-local expressions instead:
      "float on, move (monitor_w*0.45) (monitor_h*0.029), match:class ^(gsimplecal)$"

      # calc always floats
      "float on, match:title ^Calc$"
    ];

  };

  wayland.windowManager.hyprland.extraConfig = ''
    plugin {
      split-monitor-workspaces {
        count = 5
        keep_focused = 0
        enable_notifications = 0
        enable_persistent-workspaces = 1
      }
    }
  '';
}
