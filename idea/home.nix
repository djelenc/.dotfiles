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
    cinnamon.nemo-with-extensions
    pcmanfm
    gnome.nautilus
    xarchiver
    pavucontrol
    wlsunset
    nextcloud-client
    brightnessctl
    dunst
    libnotify

    # browsers
    firefox
    brave

    # utils
    libreoffice-qt
    kdePackages.okular
    zathura
    vlc

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

  stylix.targets.swaylock.enable = false;

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

      key-hl-color = "880033";
      separator-color = "00000000";

      inside-color = "00000099";
      inside-clear-color = "ffd20400";
      inside-caps-lock-color = "009ddc00";
      inside-ver-color = "d9d8d800";
      inside-wrong-color = "ee2e2400";

      ring-color = "231f20D9";
      ring-clear-color = "231f20D9";
      ring-caps-lock-color = "231f20D9";
      ring-ver-color = "231f20D9";
      ring-wrong-color = "231f20D9";

      line-color = "00000000";
      line-clear-color = "ffd204FF";
      line-caps-lock-color = "009ddcFF";
      line-ver-color = "d9d8d8FF";
      line-wrong-color = "ee2e24FF";

      text-clear-color = "ffd20400";
      text-ver-color = "d9d8d800";
      text-wrong-color = "ee2e2400";

      bs-hl-color = "ee2e24FF";
      caps-lock-key-hl-color = "ffd204FF";
      caps-lock-bs-hl-color = "ee2e24FF";
      text-caps-lock-color = "009ddc";
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
    #
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

      # x-scheme-handler/https=brave-browser.desktop
      # text/html=brave-browser.desktop
      # x-scheme-handler/http=brave-browser.desktop
      # x-scheme-handler/https=brave-browser.desktop
      # x-scheme-handler/about=brave-browser.desktop
      # x-scheme-handler/unknown=brave-browser.desktop
    };
  };

  # testiram stylix
  home.file."test.txt".text = ''
    barva = rgb(${config.lib.stylix.colors.base00})

    barva = rgb(${config.lib.stylix.colors.base00})
    barva = rgb(${config.lib.stylix.colors.base01})
    barva = rgb(${config.lib.stylix.colors.base02})
    barva = rgb(${config.lib.stylix.colors.base03})
    barva = rgb(${config.lib.stylix.colors.base04})
    barva = rgb(${config.lib.stylix.colors.base05})
    barva = rgb(${config.lib.stylix.colors.base06})
    barva = rgb(${config.lib.stylix.colors.base07})
    barva = rgb(${config.lib.stylix.colors.base08})
  '';
}
