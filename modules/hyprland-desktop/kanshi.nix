{ config, lib, pkgs, userInfo, ... }:
let
  hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
in {
  # Kanshi: Monitor configuration
  # Configuration is done together with hyprland (otherwise mirroring does not work)
  # - in hyprland, I set screen properties
  # - in here, I set which screens are on or off
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [{
          criteria = "eDP-1";
          status = "enable";
          # scale = 1.25;
          # adaptiveSync = true;
          # position = "0,0";
        }];
        profile.exec =
          "${pkgs.coreutils}/bin/sleep 1 && ${hyprctl} dispatch split-grabroguewindows";
      }
      {
        profile.name = "home";
        profile.outputs = [
          {
            criteria = "AOC Q27P1B GNXL7HA167657";
            status = "enable";
            # position = "0,0";
            # scale = 1.0;
            # adaptiveSync = true;
          }
          {
            criteria = "eDP-1";
            status = "enable";
            # scale = 1.25;
            # adaptiveSync = true;
            # position = "256,1440";
          }
        ];
      }
      {
        profile.name = "lem";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "AOC Q27P1B GNXL7HA167593";
            status = "enable";
            # position = "2560,0";
            # scale = 1.0;
            # adaptiveSync = true;
          }
          {
            criteria = "Dell Inc. DELL U2412M 0FFXD4136Y1L";
            status = "enable";
            # transform = "90";
            # position = "5120,0";
            # scale = 1.0;
            # adaptiveSync = true;
          }
        ];
      }
    ];
  };
}
