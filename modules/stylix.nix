{ config, lib, pkgs, userInfo, ... }: {
  stylix = {
    enable = true;
    autoEnable = true;
    image = ../assets/space.jpg;

    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-city-dark.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-storm.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };

    opacity = {
      applications = 1.0;
      terminal = 0.65;
      desktop = 1.0;
      popups = 1.0;
    };

    fonts = {
      sizes = {
        applications = 12;
        terminal = 17;
        desktop = 12;
        popups = 12;
      };

      monospace = {
        package = pkgs.nerdfonts;
        name = "CaskaydiaMono Nerd Font";
      };

      sansSerif = {
        # package = pkgs.dejavu_fonts;
        package = pkgs.nerdfonts;
        # name = "DejaVuSansM Nerd Font";
        name = "NotoSans NF Reg";
      };

      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };
  };

  # environment.systemPackages = with pkgs; [ lolcat ];

  # home-manager.users.${userInfo.userName}.home.packages = with pkgs; [ lolcat ];
}
