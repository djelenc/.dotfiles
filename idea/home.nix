{
  config,
  inputs,
  pkgs,
  lib,
  userInfo,
  ...
}:
rec {
  programs.home-manager.enable = true;

  # enable BT headset media control buttons
  services.mpris-proxy.enable = true;

  home.username = userInfo.user;
  home.homeDirectory = "/home/${home.username}";
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.stateVersion = "23.11";

  # browses the webs
  programs.brave = {
    enable = true;
    # commandLineArgs = [
    #   "--ozone-platform=wayland"
    #   "--use-gl=angle"
    #   "--use-angle=gl"
    #   "--enable-gpu-compositing"
    #   "--enable-gpu-rasterization"
    #   "--enable-hardware-overlays"
    #   "--enable-native-gpu-memory-buffers"
    #   "--ignore-gpu-blocklist"
    #   "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks"
    # ];
  };

  home.packages = with pkgs; [
    firefox # browses the webs
    libreoffice-qt # document manipulation
    kdePackages.okular # PDF signing
    keepassxc # storing passwords
    nextcloud-client # remote file sync and backup
    teams-for-linux

    python3
    jetbrains.pycharm-oss # python ide
    jetbrains.idea-oss # java ide
    android-studio # ide android dev
    genymotion # android emulator
    maven # java DM
    vscodium.fhs # general editor
    meld # diff/merger
    drawio # draw graphs
    inkscape # vector drawings
    zip
    unrar-wrapper # zipping and similar
    nvtopPackages.amd # gpu-top
    aider-chat-full
    teleport
    gnumake

    # screen recorder
    (import ../scripts/wf-recorder.nix { inherit pkgs; })

    # SQL related
    postgresql # psql client, server is not started
    pgmodeler
    mariadb.client
    mysql-workbench
    (import ../scripts/cfc.nix { inherit pkgs; })

    caligula # burning utility

    # sound
    ffmpeg
    audacity
    yt-dlp # download youtube videos

    vlc # videos
    obs-studio # video taking
    zotero # ref management

    # music
    audacious
    audacious-plugins

    # nix-related
    nix-index
    nixfmt

    # latex, pandoc, publishing
    texlive.combined.scheme-full
    ghostscript
    pandoc
    haskellPackages.pandoc-crossref
    diff-pdf
    diffpdf
  ];

  home.sessionPath = [ "/home/${userInfo.user}/.emacs.d/bin" ];

  # links intellij vim config
  home.file.".ideavimrc".source =
    config.lib.file.mkOutOfStoreSymlink userInfo.dotFiles + /intellij/.ideavimrc;

  # Java
  programs.java.enable = true;

  imports = [
    ../modules/hyprland-desktop
    ../modules/custom-shell.nix
    ../modules/alacritty.nix
    ../modules/nixvim.nix
    ../modules/doom-emacs.nix
    ../modules/marginaltool.nix
  ];

  programs.git = {
    enable = true;
    userName = userInfo.fullName;
    userEmail = userInfo.email;
    extraConfig.init.defaultBranch = "main";
  };

  # GTK and QT config
  gtk.enable = true;
  qt = {
    enable = true;
    # style.name = "adwaita-dark"; # "adwaita-dark";
    # platformTheme.name = "adwaita";
  };

  # virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  xdg.mimeApps = {
    enable = true;
    # installed apps
    #   exa /etc/profiles/per-user/david/share/applications/
    #   exa /run/current-system/sw/share/applications
    defaultApplications = {
      "text/plain" = [ "emacsclient.desktop" ];
      "text/org" = [ "emacsclient.desktop" ];
      "text/markdown" = [ "emacsclient.desktop" ];
      "application/json" = [ "emacsclient.desktop" ];
      "text/x-shellscript" = [ "emacsclient.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "image/jpeg" = [ "qimgv.desktop" ];
      "image/jpg" = [ "qimgv.desktop" ];
      "image/png" = [ "qimgv.desktop" ];
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

      "application/zip" = [ "xarchiver.desktop" ];
      "application/x-zip" = [ "xarchiver.desktop" ];
      "application/x-zip-compressed" = [ "xarchiver.desktop" ];

      # video for VLC
      "video/webm" = [ "vlc.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "video/x-matroska" = [ "vlc.desktop" ]; # .mkv
      "video/x-msvideo" = [ "vlc.desktop" ]; # .avi
      "video/quicktime" = [ "vlc.desktop" ]; # .mov
      "video/x-flv" = [ "vlc.desktop" ]; # .flv
      "video/x-ms-wmv" = [ "vlc.desktop" ]; # .wmv
      "video/mpeg" = [ "vlc.desktop" ]; # .mpg / .mpeg
      "video/ogg" = [ "vlc.desktop" ]; # .ogv

      # old
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
    };
  };
}
