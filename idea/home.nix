{ config, inputs, pkgs, lib, ... } :
{
  home.username = "david";
  home.homeDirectory = "/home/david";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # automount USB, disks, ...
    udiskie

    zoom-us
    nextcloud-client

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
  ];

  imports = [
    ../modules/hyprland.nix
  ];

  # emacs and doom
  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs29;
      extraPackages = (epkgs: [
        pkgs.mu.mu4e
        epkgs.mu4e
      ]);
      overrides = self: super: {
        org = self.elpaPackages.org;
      };
    };
    mu.enable = true;
    msmtp.enable = true;
    mbsync.enable = true;
  };

  xdg.portal.config.common.default = "*";
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # git
  programs.git = {
    enable = true;
    userName = "David Jelenc";
    userEmail = "david.jelenc@fri.uni-lj.si";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  # ENV
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
