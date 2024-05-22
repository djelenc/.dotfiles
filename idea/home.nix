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
    swaylock-effects
    cinnamon.nemo-with-extensions
    pcmanfm
    gnome.nautilus
    swww
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
    fuzzel
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

  gtk.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = [ "emacs.desktop" ];
      "application/pdf" =
        [ "org.pwmt.zathura-pdf-mupdf.desktop" "okular.desktop" ];
      "image/jpeg" = [ "nsxiv.desktop" "shotwell.desktop" ];
      "image/jpg" = [ "nsxiv.desktop" "shotwell.desktop" ];
      "image/png" = [ "nsxiv.desktop" "shotwell.desktop" ];
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
}
