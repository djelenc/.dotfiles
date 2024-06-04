{ config, inputs, pkgs, lib, ... }: {
  programs.home-manager.enable = true;

  home.username = "david";
  home.homeDirectory = "/home/david";
  home.sessionVariables = { EDITOR = "nvim"; };
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # desktop related
    networkmanagerapplet
    gsimplecal
    dconf
    gnome.nautilus
    gnome.adwaita-icon-theme

    xarchiver
    pavucontrol
    wlsunset
    nextcloud-client
    brightnessctl
    libnotify

    # browsers
    firefox
    brave

    # utils
    libreoffice-qt
    kdePackages.okular
    zathura
    vlc
    wl-clipboard

    # images
    nsxiv
    shotwell

    # programming
    python3
    jetbrains.pycharm-community-bin
    vscodium.fhs
    gedit

    # app launchers
    rofi-wayland
    rofi-power-menu

    # misc
    fzf
    wireplumber
    nix-index
    nixfmt-classic
    fontpreview
    zoom-us
  ];

  imports = [
    ../modules/hyprland.nix
    ../modules/alacritty.nix
    ../modules/waybar.nix
    ../modules/doom-emacs.nix
  ];

  services.swayosd.enable = true;

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

  programs.git = {
    enable = true;
    userName = "David Jelenc";
    userEmail = "david.jelenc@fri.uni-lj.si";
    extraConfig.init.defaultBranch = "main";
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = true;
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "CaskaydiaMono Nerd Font";
        dpi-aware = lib.mkForce "yes";
        icon-theme = "hicolor";
        icons-enabled = "yes";
        lines = 25;
        width = 70;
        horizontal-pad = 40;
        vertical-pad = 8;
        inner-pad = 10;
      };
    };
  };

  stylix.targets = { nixvim.enable = false; };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      font = "CaskaydiaMono Nerd Font";
      clock = true;
      timestr = "%R";
      datestr = "%A, %e. %B";
      grace = 2;
      screenshots = true;
      fade-in = 0.2;
      effect-blur = "20x2";
      effect-greyscale = true;
      effect-scale = 0.3;
      indicator = true;
      indicator-radius = 400;
      indicator-thickness = 20;
      indicator-caps-lock = true;
      disable-caps-lock-text = true;
    };
  };

  gtk.enable = true;
  qt.enable = true;

  xdg.mimeApps = {
    enable = true;
    # installed apps
    # user:
    #   exa /etc/profiles/per-user/david/share/applications/
    # system:
    #   exa /run/current-system/sw/share/applications
    # example: ${config.lib.stylix.colors.base00}
    defaultApplications = {
      "text/plain" = [ "emacs.desktop" ];
      "text/org" = [ "emacs.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "image/jpeg" = [ "nsxiv.desktop" ];
      "image/jpg" = [ "nsxiv.desktop" ];
      "image/png" = [ "nsxiv.desktop" ];
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

      "application/zip" = [ "xarchiver.desktop" ];
      "application/x-zip" = [ "xarchiver.desktop" ];
      "application/x-zip-compressed" = [ "xarchiver.desktop" ];

      "video/*" = [ "vlc.desktop" ];

      # old
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
    };
  };
}
