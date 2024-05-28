{ inputs, pkgs, lib, xdg, config, ... }: {
  xdg.portal = {
    config.common.default = "*";
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    plugins = [
      # inputs.hyprland-virtual-desktops.packages.${pkgs.system}.virtual-desktops
    ];

    settings = {
      monitor = ",preferred,auto,1.25";

      xwayland = { force_zero_scaling = true; };

      exec-once = [
        "nm-applet --indicator"
        "waybar"
        "blueman-applet"
        "wlsunset -l 46 -L 14.5"
        "nextcloud"
      ];

      env = [ "XCURSOR_SIZE,24" "GDK_SCALE,1.25" ];

      input = {
        kb_layout = "us,si";
        kb_options = "grp:win_space_toggle";
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
        "col.active_border" =
          lib.mkDefault "rgba(33ccffee) rgba(00ff99ee) 45deg";
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
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = lib.mkDefault "rgba(1a1a1aee)";
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

      master = { new_is_master = true; };

      gestures = { workspace_swipe = "on"; };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, T, exec, alacritty"
        "$mainMod, Q, killactive, "
        "$mainMod, M, fullscreen, 1"
        "$mainMod SHIFT, Q, exit, "
        "$mainMod, F, exec, nautilus"
        "$mainMod, G, togglefloating, "
        "$mainMod, P, exec, rofi -show power-menu -modi power-menu:rofi-power-menu -font 'MonaspiceKr Nerd Font 17'"
        "$mainMod, O, togglesplit, # dwindle"
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        "$mainMod CONTROL, j, workspace, +1"
        "$mainMod CONTROL, k, workspace, -1"
        "$mainMod SHIFT, j, movetoworkspace, +1"
        "$mainMod SHIFT, k, movetoworkspace, -1"
        # Assumes the monitors are side by side (horizontal)
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"

        # TODO
        "LALT,Tab,cyclenext,"
        "LALT,Tab,bringactivetotop,"

        ", xf86monbrightnessup, exec, brightnessctl set 10%+"
        ", xf86monbrightnessdown, exec, brightnessctl set 10%-"
        ", xf86audioraisevolume, exec, wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%+"
        ", xf86audiolowervolume, exec, wpctl set-volume -l 1.0 @DEFAULT_SINK@ 5%-"
        ", xf86audiomute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
        "$mainMod, escape, exec, swaylock"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      "bindr" = "$mainMod, SUPER_L, exec, fuzzel";

      windowrulev2 = [
        "float,class:^(org.kde.polkit-kde-authentication-agent-1)$"
        "float,class:^(pavucontrol)$"
        "float,class:^(com.nextcloud.desktopclient.nextcloud)$"
        "move 45% 2.9%,class:^(gsimplecal)$"
      ];
    };

    # extraConfig = ''
    #   plugin {
    #     virtual-desktops {
    #       cycleworkspaces = 0
    #       rememberlayout = size
    #       notifyinit = 0
    #       verbose_logging = 0
    #     }
    #   }'';
  };
}
