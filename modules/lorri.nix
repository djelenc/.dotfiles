{ config, lib, pkgs, ... }: {
  services.lorri.enable = true;
  home.packages = [ pkgs.direnv ];
}
