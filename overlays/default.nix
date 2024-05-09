{ config, pkgs, lib, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      msmtp = prev.msmtp.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "marlam";
          repo = "msmtp-mirror";
          rev = "msmtp-1.8.26";
          hash = "sha256-MV3fzjjyr7qZw/BbKgsSObX+cxDDivI+0ZlulrPFiWM=";
        };
      });
    })
  ];
}
