{
  description = "Davidov NixOS";

  inputs = {
    nixpkgs = { url = "nixpkgs/nixos-unstable"; };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      follows = "hyprland-virtual-desktops/hyprland";
    };

    hyprland-virtual-desktops = {
      # url = "github:djelenc/hyprland-virtual-desktops";
      url = "github:levnikmyskin/hyprland-virtual-desktops";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake.url = "github:xremap/nix-flake";
    stylix.url = "github:danth/stylix";

    # anyrun = {
    #   url = "github:Kirottu/anyrun";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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
          ];
        };
      };
    };
}
