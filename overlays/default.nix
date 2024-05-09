{ config, pkgs, lib, ... }: {
  nixpkgs.overlays = [
    # force msmtp version
    (final: prev: {
      msmtp = prev.msmtp.overrideAttrs (previousAttrs: rec {
        version = "1.8.26";
        src = prev.fetchFromGitHub {
          owner = "marlam";
          repo = "msmtp";
          rev = "msmtp-${version}";
          hash = "sha256-MV3fzjjyr7qZw/BbKgsSObX+cxDDivI+0ZlulrPFiWM=";
        };
      });
    })

    # run brave under wayland
    (self: super: {
      brave = super.brave.override {
        commandLineArgs =
          "--enable-features=UseOzonePlatform --ozone-platform=wayland";
      };
    })
  ];
}
