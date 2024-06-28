{ config, inputs, pkgs, pkgs-24_05, lib, userInfo, ... }: rec {
  programs.home-manager.enable = true;

  home.username = userInfo.userName;
  home.homeDirectory = "/home/${home.username}";
  home.sessionVariables = { EDITOR = "nvim"; };
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    firefox # browses the webs
    brave # browses the webs
    libreoffice-qt # document manipulation
    kdePackages.okular # PDF signing
    keepassxc # storing passwords
    nextcloud-client # remote file sync and backup
    (zoom-us.overrideAttrs (old: {
      # to allow screen sharing
      postFixup = old.postFixup + ''
        wrapProgram $out/bin/zoom --unset XDG_SESSION_TYPE
        wrapProgram $out/bin/zoom-us --unset XDG_SESSION_TYPE
      '';
    }))

    python3
    jetbrains.pycharm-community-bin # python ide
    jetbrains.idea-community-src # java ide
    android-studio # ide andorid dev
    maven # java DM
    vscodium.fhs # general editor
    meld

    vlc # videos
    obs-studio # video taking

    # nix-related
    nix-index
    nixfmt-classic
  ];

  # Java
  programs.java.enable = true;

  imports = [
    ../modules/hyprland-desktop
    ../modules/custom-shell.nix
    ../modules/alacritty.nix
    ../modules/nixvim.nix
    ../modules/doom-emacs.nix
    ../modules/sops-nix.nix
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
    style.name = "adwaita-dark"; # "adwaita-dark";
    platformTheme = "gnome";
  };

  xdg.mimeApps = {
    enable = true;
    # installed apps
    #   exa /etc/profiles/per-user/david/share/applications/
    #   exa /run/current-system/sw/share/applications
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
