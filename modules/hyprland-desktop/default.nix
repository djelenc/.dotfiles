{ inputs, pkgs, lib, xdg, config, ... }: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    plugins = [
      (pkgs.callPackage
        ({ lib, fetchFromGitHub, cmake, hyprland, hyprlandPlugins, }:
          hyprlandPlugins.mkHyprlandPlugin pkgs.hyprland {
            pluginName = "virtual-desktops";
            version = "2.2.4";

            src = fetchFromGitHub {
              owner = "levnikmyskin";
              repo = "hyprland-virtual-desktops";
              rev = "8eea25c8bc162f9259f2b249cd864c3c8a540fd1";
              hash = "sha256-bJ6fDQiMH4ro0TuZp35FnV5kNdOXNNTi8d44GcEZYVs=";
            };

            installPhase = ''
              mkdir -p $out/lib
              cp virtual-desktops.so $out/lib/libvirtual-desktops.so
            '';

            meta = {
              homepage =
                "https://github.com/levnikmyskin/hyprland-virtual-desktops";
              description =
                "A plugin for the Hyprland compositor, implementing virtual-desktop functionality.";
              license = lib.licenses.bsd3;
              platforms = lib.platforms.linux;
              maintainers = with lib.maintainers; [ levnikmyskin ];
            };
          }) { })
    ];

    extraConfig = ''
      plugin {
          virtual-desktops {
              notifyinit = 0
              verbose_logging = 0
              cycleworkspaces = 0
          }
      }
    '';

  };

  imports = [ ./waybar.nix ./config.nix ];

  xdg.portal = {
    config.common.default = "*";
    enable = true;
    extraPortals =
      [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
  };

  # utilities
  home.packages = with pkgs; [
    networkmanagerapplet # network applet
    gnome-disk-utility # disks utility
    gsimplecal # calendar applet
    dconf # desktop properties
    nautilus # file explorer
    adwaita-icon-theme # icons
    xarchiver # zip and other archives
    pavucontrol # control sounds
    wlsunset # redshift
    brightnessctl # control brightness
    libnotify # notifications
    wl-clipboard # fix clipboard
    nsxiv # images
    gedit # text editor
    fontpreview # display fonts
    hyprcursor # cursor for hyprland
    xwaylandvideobridge # to make screensharing work
  ];

  # zathura (PDF reader)
  programs.zathura = {
    enable = true;
    options = {
      recolor = true;
      selection-clipboard = "clipboard";
    };
  };

  # screen lock
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      font = config.stylix.fonts.monospace.name;
      clock = true;
      timestr = "%R";
      # datestr = "%A, %e. %B";
      datestr = "%e. %B";
      # grace = 2;
      screenshots = true;
      # fade-in = 0.2;
      effect-blur = "20x2";
      # effect-greyscale = true;
      effect-scale = 0.3;
      indicator = true;
      indicator-radius = 400;
      indicator-thickness = 20;
      indicator-caps-lock = true;
      disable-caps-lock-text = true;
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
