{ config, lib, pkgs, ... }: {
  stylix = {
    autoEnable = true;
    # required, but does not work?!
    image = pkgs.fetchurl {
      url =
        "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
      sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    };

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
      terminal = 0.85;
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
}
