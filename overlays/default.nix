{ config, pkgs, lib, ... }: {
  nixpkgs.overlays = [
    # run brave under wayland
    (self: super: {
      brave = super.brave.override {
        commandLineArgs =
          "--enable-features=UseOzonePlatform --ozone-platform=wayland";
      };
    })
  ];
}
