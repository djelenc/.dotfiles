{
  inputs,
  pkgs,
  lib,
  xdg,
  config,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;

    # Use the Hyprland/XDPH packages from the NixOS module.
    package = null;
    portalPackage = null;

    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
    configType = "lua";

    extraLuaFiles = {
      animations = ./lua/animations.lua;
      startup = ./lua/startup.lua;
      split_monitor_workspaces = ./lua/split_monitor_workspaces.lua;
      binds = ./lua/binds.lua;
      gestures = ./lua/gestures.lua;
      window_rules = ./lua/window_rules.lua;
    };

    # split-monitor-workspaces is now a Lua package, not a compiled Hyprland plugin.
    plugins = [ ];
  };

  # pyprland -- hyprland extensions
  xdg.configFile."pypr/config.toml".text = ''
    [pyprland]
    plugins = [
      "magnify"
    ]
  '';

  # Hyprland 0.56 changed HLMonitor:set_workspace() from a table argument
  # ({ workspace = target }) to a workspace selector/object directly. Patch the
  # Lua plugin until split-monitor-workspaces adopts the new API upstream.
  xdg.configFile."hypr/plugins/split-monitor-workspaces".source =
    pkgs.runCommand "split-monitor-workspaces-hyprland-0.56" { }
      ''
        cp -R ${inputs.split-monitor-workspaces}/lua "$out"
        chmod -R u+w "$out"
          substituteInPlace "$out/dispatchers.lua" \
              --replace-fail \
                  'monitor:set_workspace({ workspace = target })' 'monitor:set_workspace(target)'
      '';

  # Additional launcher commands
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

    my-calc = {
      name = "Calculator [bc]";
      exec = "${pkgs.alacritty}/bin/alacritty -t Calc -e bc -l -q";
      terminal = true;
      categories = [ "Applications" ];
    };
  };

  imports = [
    ./waybar.nix
    ./config.nix
    ./kanshi.nix
  ];

  # utilities
  home.packages = with pkgs; [
    networkmanagerapplet # network applet
    gnome-disk-utility # disks utility
    gsimplecal # calendar applet
    dconf # desktop properties
    nautilus # file explorer
    adwaita-icon-theme # icons
    pwvucontrol # control sounds
    wlsunset # redshift
    brightnessctl # control brightness
    libnotify # notifications
    wl-clipboard # fix clipboard
    cliphist
    hyprshot # screen shots
    slurp # screen shots
    grim # screen shots
    qimgv # images
    xarchiver # zipping
    simple-scan # scanning
    gedit # text editor
    fontpreview # display fonts
    hyprcursor # cursor for hyprland
    # kdePackages.xwaylandvideobridge # to make screensharing work
    qt5.qtwayland
    qt6.qtwayland
    inputs.pyprland.packages.${pkgs.stdenv.hostPlatform.system}.pyprland # pyprland plugins
  ];

  home.sessionVariables.HYPRSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";

  # zathura (PDF reader)
  programs.zathura = {
    enable = true;
    options = {
      recolor = false; # light mode by default, toggle with C-r
      selection-clipboard = "clipboard";
    };
  };

  # polkit agent
  services.hyprpolkitagent.enable = true;

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

      background = lib.mkForce [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
    };
  };

  # program launcher
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "CaskaydiaMono Nerd Font";
        dpi-aware = lib.mkForce "yes";
        # icon-theme = "hicolor";
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
  services.mako = {
    enable = true;
    settings = {
      actions = true;
      anchor = "top-right";
      font = lib.mkForce "CaskaydiaMono Nerd Font";
      default-timeout = 7000;
      height = 100;
      width = 300;
      icons = true;
      ignore-timeout = false;
      layer = "top";
      margin = 10;
      padding = 10;
      markup = true;
    };
  };
}
