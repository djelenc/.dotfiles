{ config, lib, pkgs, userInfo, ... }: {
  # Kanshi: Monitor configuration
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";

    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [{
          criteria = "eDP-1";
          status = "enable";
          scale = 1.25;
          adaptiveSync = true;
          position = "0,0";
        }];
      }
      {
        profile.name = "home-docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "AOC Q27P1B GNXL7HA167657";
            position = "2560,0";
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
          }
          {
            criteria =
              "Philips Consumer Electronics Company 231PQPY UHB1430018671";
            transform = "90";
            position = "5120,0";
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
          }
        ];
      }
      # {
      #   profile.name = "mirror";
      #   profile.outputs = [
      #     {
      #       criteria = "*";
      #       status = "enable";
      #       scale = 1.25;
      #       adaptiveSync = true;
      #       position = "0,0";
      #     }
      #     {
      #       criteria = "eDP-1";
      #       status = "enable";
      #       scale = 1.25;
      #       adaptiveSync = true;
      #       position = "0,0";
      #     }
      #   ];
      # }
      {
        profile.name = "home-extra-monitor";
        profile.outputs = [

          {
            criteria = "AOC Q27P1B GNXL7HA167657";
            position = "0,0";
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
          }
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.25;
            adaptiveSync = true;
            position = "256,1440";
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
            position = "2560,0";
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
          }
          {
            criteria = "Dell Inc. DELL U2412M 0FFXD4136Y1L";
            transform = "90";
            position = "5120,0";
            status = "enable";
            scale = 1.0;
            adaptiveSync = true;
          }
        ];
      }
    ];
  };
}
