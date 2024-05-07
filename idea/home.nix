{ config, inputs, pkgs, lib, ... }: {
  programs.home-manager.enable = true;

  home.username = "david";
  home.homeDirectory = "/home/david";
  home.sessionVariables = { EDITOR = "nvim"; };
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # FM
    pcmanfm
    nextcloud-client

    # utils
    zoom-us

    # emacs
    ripgrep
    coreutils
    fd
    clang
    shellcheck
    graphviz
    shfmt
    imagemagick
    pandoc

    # desktop related
    networkmanagerapplet
    gsimplecal
    hyprlock
    # swaylock
    dconf # stylix won't run without it
    cinnamon.nemo-with-extensions
    swww
    xarchiver
    pavucontrol
    wlsunset

    firefox
    brave
    kdePackages.okular
    libreoffice-qt
    jetbrains.pycharm-community-bin
    vscodium.fhs
    vlc
    fontpreview

    # app launchers
    fuzzel
    rofi-wayland
    rofi-power-menu
    # inputs.anyrun.packages.${system}.anyrun

    brightnessctl
    dunst
    libnotify

    # dictionaries
    hunspell
    hunspellDicts.en_US-large
  ];

  imports = [
    ../modules/hyprland.nix
    ../modules/alacritty.nix
    ../modules/waybar.nix
    # inputs.stylix.homeManagerModules.stylix
  ];

  # stylix = {
  #   image = pkgs.fetchurl {
  #     url =
  #       "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
  #     sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
  #   };

  #   # polarity = "dark";
  #   targets.hyprland.enable = true;
  # };

  # emacs and doom
  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk; # emacs29;
      extraPackages = (epkgs: [ pkgs.mu.mu4e epkgs.mu4e ]);
      overrides = self: super: { org = self.elpaPackages.org; };
    };
    mu.enable = true;
    msmtp.enable = true;
    mbsync.enable = true;

    git = {
      enable = true;
      userName = "David Jelenc";
      userEmail = "david.jelenc@fri.uni-lj.si";
      extraConfig = { init = { defaultBranch = "main"; }; };
    };
  };

  gtk = {
    enable = true;
    theme.name = "adw-gtk3";
    cursorTheme.name = "Bibata-Modern-Ice";
    iconTheme.name = "GruvboxPlus";
  };
}
