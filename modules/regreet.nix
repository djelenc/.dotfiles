{ config, lib, pkgs, ... }:

{
  # Regreet login/display manager
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = lib.mkDefault ../assets/gruvbox-nix.png;
        fit = "Cover";
      };
      # env = { ENV_VARIABLE = "value"; };

      GTK = with config.stylix.fonts; {
        application_prefer_dark_theme = true;
        cursor_theme_name = lib.mkDefault "Adwaita";
        font_name = lib.mkDefault "Cantarell 16";
        icon_theme_name = lib.mkDefault "Adwaita";
        theme_name = lib.mkDefault "Adwaita";
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
