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
    hyprlock
    dconf
    cinnamon.nemo-with-extensions
    swww
    xarchiver
    pavucontrol
    wlsunset
    pcmanfm
    nextcloud-client
    brightnessctl
    dunst
    libnotify

    # user programs
    firefox
    brave
    kdePackages.okular
    libreoffice-qt
    jetbrains.pycharm-community-bin
    vscodium.fhs
    vlc
    fontpreview
    zoom-us
    python3

    # app launchers
    fuzzel
    rofi-wayland
    rofi-power-menu

    # dictionaries
    hunspell
    hunspellDicts.en_US-large

    # misc
    fzf
    wireplumber
    nix-index
    nixfmt-classic
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

  gtk = {
    enable = true;
    theme.name = "adw-gtk3";
    cursorTheme.name = "Bibata-Modern-Ice";
    iconTheme.name = "GruvboxPlus";
  };
}
