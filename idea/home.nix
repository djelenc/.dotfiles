{ config, inputs, pkgs, lib, ... } :
{
  home.username = "david";
  home.homeDirectory = "/home/david";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
  ];

  # imports = [
  #   inputs.hyprland-virtual-desktops.packages.${pkgs.system}.virtual-desktops
  # ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    # package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = false;

    plugins = [
      inputs.hyprland-virtual-desktops.packages.${pkgs.system}.virtual-desktops
    ];

    extraConfig = lib.fileContents ./hyprland.conf;
  };

  xdg.portal.config.common.default = "*";
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # basic configuration of git, please change to your own
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
