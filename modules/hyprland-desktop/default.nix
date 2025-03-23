{ inputs, pkgs, lib, xdg, config, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    plugins = [
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];
  };

  # pyprland -- hyprland extensions
  xdg.configFile."hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = [
    "magnify"
    ]
  '';

  # Power management as desktop commands
  # (so they apper in launcher)
  xdg.desktopEntries = {
    suspend = {
      name = "Suspend";
      exec = "systemctl suspend";
      terminal = false;
      categories = [ "System" ];
    };
    power-off = {
      name = "Power off";
      exec = "systemctl poweroff";
      terminal = false;
      categories = [ "System" ];
    };
    reboot = {
      name = "Reboot";
      exec = "systemctl reboot";
      terminal = false;
      categories = [ "System" ];
    };
  };

  imports = [ ./waybar.nix ./config.nix ./kanshi.nix ];

  # utilities
  home.packages = with pkgs; [
    networkmanagerapplet # network applet
    gnome-disk-utility # disks utility
    gsimplecal # calendar applet
    dconf # desktop properties
    nautilus # file explorer
    adwaita-icon-theme # icons
    # xarchiver # zip and other archives
    pavucontrol # control sounds
    wlsunset # redshift
    brightnessctl # control brightness
    libnotify # notifications
    wl-clipboard # fix clipboard
    cliphist
    qimgv # images
    xarchiver # zipping
    simple-scan # scanning
    gedit # text editor
    fontpreview # display fonts
    hyprcursor # cursor for hyprland
    kdePackages.xwaylandvideobridge # to make screensharing work
    inputs.pyprland.packages.${pkgs.system}.pyprland # pyprland plugins
  ];

  # zathura (PDF reader)
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      selection-clipboard = "clipboard";
    };
  };

  # idling
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # screen lock
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = false;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = lib.mkForce [{
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
      }];
    };
  };

  # program launcher
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "CaskaydiaMono Nerd Font";
        dpi-aware = lib.mkForce "yes";
        icon-theme = "hicolor";
        icons-enabled = "yes";
        lines = 10;
        width = 35;
        horizontal-pad = 40;
        vertical-pad = 8;
        inner-pad = 10;
      };

      colors = with config.lib.stylix.colors; {
        background = lib.mkForce "${base00}C0";
        text = lib.mkForce "${base05}FF";
        match = lib.mkForce "${base04}FF";
        selection = lib.mkForce "${base02}40";
        selection-text = lib.mkForce "${base0A}FF";
        selection-match = lib.mkForce "${base09}FF";
        border = lib.mkForce "${base0D}FF";
      };
    };
  };

  # SwayOSD: Indicators for sound volume, brightness
  services.swayosd = {
    enable = true;
    topMargin = 0.9;
  };

  # System notifications
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 60;
        font = lib.mkForce "CaskaydiaMono Nerd Font";
      };
    };
  };
}
