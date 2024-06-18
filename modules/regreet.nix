{ config, lib, pkgs, ... }:

{
  # Regreet login/display manager
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = ../assets/gruvbox-nix.png;
        fit = "Cover";
      };
      # env = { ENV_VARIABLE = "value"; };

      GTK = with config.stylix.fonts; {
        application_prefer_dark_theme = true;
        cursor_theme_name = "Adwaita";
        font_name = "Cantarell 16";
        icon_theme_name = "Adwaita";
        theme_name = "Adwaita";
      };

      commands = {
        reboot = [ "systemctl" "reboot" ];
        poweroff = [ "systemctl" "poweroff" ];
      };

      appearance = { greeting_msg = "Log-in"; };
      extraCss = with config.lib.stylix.colors; ''
        /* unsure how */
      '';
    };
  };
}
