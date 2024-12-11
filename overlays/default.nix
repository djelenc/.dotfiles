{ config, pkgs, lib, ... }: {
  nixpkgs.overlays = [
    # run brave under wayland
    (self: super: {
      brave = super.brave.override {
        commandLineArgs =
          "--enable-features=UseOzonePlatform --ozone-platform=wayland";
      };
    })
    # run drawio under wayland
    (self: super: {
      drawio = super.drawio.overrideAttrs (oldAttrs: {
        desktopItems = [
          (super.makeDesktopItem {
            name = "drawio";
            exec = "drawio %U --ozone-platform-hint=auto";
            icon = "drawio";
            desktopName = "drawio";
            comment = "draw.io desktop";
            mimeTypes =
              [ "application/vnd.jgraph.mxfile" "application/vnd.visio" ];
            categories = [ "Graphics" ];
            startupWMClass = "draw.io";
          })
        ];
      });
    })
  ];
}
