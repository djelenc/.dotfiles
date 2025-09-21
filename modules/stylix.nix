{ config, lib, pkgs, userInfo, ... }: {
  stylix = {
    enable = true;
    autoEnable = true;
    image = ../assets/galaxy2.jpg;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 30;
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
        package = pkgs.nerd-fonts.caskaydia-mono;
        name = "CaskaydiaMono Nerd Font";
      };

      sansSerif = {
        package = pkgs.nerd-fonts.noto;
        name = "NotoSans NF Reg";
      };

      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };
  };
}
