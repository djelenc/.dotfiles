{ config, lib, pkgs, inputs, ... }: {
  # hyprland config
  wayland.windowManager.hyprland.settings = {
    # monitor = ",preferred,auto,1.25";
    monitor = [
      # name, resolution, position, scale
      "eDP-1, preferred, auto, 1.25, vrr, 1"
      "desc:AOC Q27P1B GNXL7HA167657, preferred, auto-up, 1"
      ", preferred, auto, 1, mirror, eDP-1"
    ];

    xwayland = { force_zero_scaling = true; };

    exec-once = [
      "${pkgs.waybar}/bin/waybar"
      "${pkgs.wlsunset}/bin/wlsunset -l 46 -L 14.5"
      "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
      "${pkgs.blueman}/bin/blueman-applet"
      "${pkgs.nextcloud-client}/bin/nextcloud"
      "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch cliphist store # Stores only text data"
      "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store # Stores only image data"
    ];

    env = [ "GDK_SCALE,1.25" ];

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
      # drop_shadow = "yes";
      # shadow_range = 4;
      # shadow_render_power = 3;
      # "col.shadow" = lib.mkDefault "rgba(1a1a1aee)";
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

    # master = { new_is_master = true; };

    gestures = { workspace_swipe = "on"; };

    misc = {
      force_default_wallpaper = 0;
      disable_hyprland_logo = true;
    };

    "$mainMod" = "SUPER";

    bind = [
      "$mainMod, T, exec, alacritty"
      "$mainMod, Q, killactive, "
      "$mainMod, M, fullscreen, 1"
      "$mainMod SHIFT, Q, exit, "
      "$mainMod, F, exec, nautilus"
      "$mainMod, G, togglefloating, "
      "$mainMod, O, togglesplit, # dwindle"
      "$mainMod, h, movefocus, l"
      "$mainMod, l, movefocus, r"
      "$mainMod, k, movefocus, u"
      "$mainMod, j, movefocus, d"
      "$mainMod CONTROL, j, workspace, +1"
      "$mainMod CONTROL, k, workspace, -1"
      "$mainMod SHIFT, j, movetoworkspace, +1"
      "$mainMod SHIFT, k, movetoworkspace, -1"
      "$mainMod SHIFT, h, movewindow, l"
      "$mainMod SHIFT, l, movewindow, r"

      # TODO: should be MRU not cycling
      "$mainMod, Tab, cyclenext, "
      "$mainMod, Tab, bringactivetotop, "

      ", xf86audiomute, exec, swayosd-client --output-volume mute-toggle"
      ", xf86audiomicmute, exec, swayosd-client --input-volume mute-toggle"
      "$mainMod, escape, exec, swaylock"
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
    bindl = [ ",switch:off:Lid Switch, exec, swaylock" ];

    # execute on release
    bindr = "$mainMod, SUPER_L, exec, pkill fuzzel || fuzzel";

    windowrulev2 = [
      "float,class:^(org.kde.polkit-kde-authentication-agent-1)$"
      "float,class:^(pavucontrol)$"
      "float,class:^(com.nextcloud.desktopclient.nextcloud)$"
      "float,class:(blueman)"
      "float,class:^(org.keepassxc.KeePassXC)$"
      "float,initialTitle:(All Files)"
      "move 45% 2.9%,class:^(gsimplecal)$"

      # to make xwayladvideobridge work
      # https://wiki.hyprland.org/0.41.2/Useful-Utilities/Screen-Sharing/#xwayland
      # "opacity 0.0 override,class:^(xwaylandvideobridge)$"
      # "noanim,class:^(xwaylandvideobridge)$"
      # "noinitialfocus,class:^(xwaylandvideobridge)$"
      # "maxsize 1 1,class:^(xwaylandvideobridge)$"
      # "noblur,class:^(xwaylandvideobridge)$"
    ];
  };
}
