{
  description = "Davidov NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      # follows = "hyprland-virtual-desktops/hyprland";
    };

    # hyprland-virtual-desktops.url =
    #   "github:levnikmyskin/hyprland-virtual-desktops";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake.url = "github:xremap/nix-flake";
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations = {
        idea = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./idea/configuration.nix
            inputs.home-manager.nixosModules.default

            (import ./overlays)
          ];
        };
      };
    };
}
