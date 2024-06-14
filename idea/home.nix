{ config, inputs, pkgs, lib, ... }:
let dotFilesRoot = "/home/david/.dotfiles";
in {
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
    jetbrains.idea-community-src
    android-studio
    maven
    vscodium.fhs
    gedit

    # app launchers
    rofi-wayland
    rofi-power-menu

    # misc
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
    ../modules/nixvim.nix
    ../modules/sops-nix.nix
  ];

  # terminal-related
  programs.starship.enable = true;
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    defaultKeymap = "emacs";

    completionInit = ''
      # default
      autoload -U compinit && compinit

      # C-w and M-d delete only to the first /
      autoload -U select-word-style
      select-word-style bash

      # case-insensitive tab-completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      # highlight tab-completed entry
      zstyle ':completion:*' menu select
    '';

    shellAliases = {
      # the usual ls-ing with exa
      l = "exa --icons --hyperlink"; # basic
      ll = "exa -la --icons --hyperlink --git --header"; # details
      lt = "exa --icons --tree --hyperlink"; # tree

      # git
      glg = "git log --oneline";
      gst = "git status";
      gdf = "git diff";
      gco = "git checkout";

      # managing nixos configuration
      cedit = "nvim -c 'cd ${dotFilesRoot}' ${dotFilesRoot}";
      cdiff = "git -C ${dotFilesRoot} diff";
      csave = ''
        git -C ${dotFilesRoot} commit -aem "$(hostname)@$(readlink /nix/var/nix/profiles/system | cut -d- -f2)"'';
      cpush = "git -C ${dotFilesRoot} push origin main";
      cpull = "git -C ${dotFilesRoot} pull origin main";
      cst = "git -C ${dotFilesRoot} status";
      clg = "git -C ${dotFilesRoot} log --oneline";
    };
  };
  programs.fzf.enable = true;

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

  programs.java.enable = true;

  # programs.zellij = {
  #   enable = true;
  #   enableBashIntegration = true;
  # };

  programs.git = {
    enable = true;
    userName = "David Jelenc";
    userEmail = "david.jelenc@fri.uni-lj.si";
    extraConfig.init.defaultBranch = "main";
  };

  programs.eza = {
    enable = true;
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

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      font = config.stylix.fonts.monospace.name;
      clock = true;
      timestr = "%R";
      datestr = "%A, %e. %B";
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
