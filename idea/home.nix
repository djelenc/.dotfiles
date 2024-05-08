{ config, inputs, pkgs, lib, ... }:
let
  # Inspiration: https://github.com/NixOS/nixpkgs/issues/108480#issuecomment-1115108802
  isync-oauth2 = with pkgs;
    buildEnv {
      name = "isync-oauth2";
      paths = [ isync ];
      pathsToLink = [ "/bin" ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/mbsync" \
          --prefix SASL_PATH : "${cyrus_sasl}/lib/sasl2:${cyrus-sasl-xoauth2}/lib/sasl2"
      '';
    };
in {

  # untested yet
  nixpkgs.overlays = [
    (final: prev: {
      msmtp = prev.msmtp.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          wner = "marlam";
          repo = "msmtp-mirror";
          rev = "msmtp-1.8.26";
          hash = "";
        };
      });
    })
  ];

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

    # mbsync requries xoauth2
    oauth2ms
    cyrus_sasl
    cyrus-sasl-xoauth2
    isync-oauth2

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
    mbsync.package = isync-oauth2;

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

  accounts.email = {
    accounts.fri = {
      primary = true;
      flavor = "outlook.office365.com";
      realName = "David Jelenc";
      userName = "davidjelenc@fri1.uni-lj.si";
      address = "david.jelenc@fri.uni-lj.si";
      passwordCommand = "oauth2ms";

      mbsync = {
        enable = true;
        create = "both";
        expunge = "both";
        patterns = [
          "Archive"
          "Drafts"
          "Deleted Items"
          "Inbox"
          "Junk Email"
          "Sent Email"
        ];
        extraConfig.account.AuthMechs = "XOAUTH2";
      };

      msmtp = {
        enable = true;
        extraConfig.auth = "xoauth2";
        extraConfig.passwordeval = "oauth2ms";
      };

      mu.enable = true;
    };
  };
}
