{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [
    # zotero update fail: keep it working
    (
      final: prev:
      let
        zoteroPkgs = import inputs.nixpkgs-zotero-good {
          system = prev.stdenv.hostPlatform.system;
          config = prev.config;
        };
      in
      {
        zotero = zoteroPkgs.zotero;
      }
    )
    # hallucinator for references
    (final: prev: {
      hallucinator-bin = final.callPackage ./hallucinator-bin.nix { };
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
