{ config, lib, pkgs, ... }: {
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "david" ];
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.draganddrop = true;
  virtualisation.virtualbox.guest.clipboard = true;
}
