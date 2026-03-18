{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        goodPkgs = import inputs.nixpkgs-electron-good {
          system = prev.stdenv.hostPlatform.system;
          config = prev.config;
        };
      in
      {
        inherit (goodPkgs) electron_39 electron_39-unwrapped;
      }
    )
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
            mimeTypes = [
              "application/vnd.jgraph.mxfile"
              "application/vnd.visio"
            ];
            categories = [ "Graphics" ];
            startupWMClass = "draw.io";
          })
        ];
      });
    })
  ];
}
