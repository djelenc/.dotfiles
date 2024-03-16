{inputs, pkgs, lib, hyprland-virtual-desktops, ...} :
{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    systemd.enable = false;

    plugins = [
      hyprland-virtual-desktops.packages.${pkgs.system}.virtual-desktops
    ];

    extraConfig = lib.fileContents ./hyprland.conf;
  };
}
