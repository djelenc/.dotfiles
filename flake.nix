{
  description = "Davidov NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    unstable-nixpkgs.url = "nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    xremap-flake.url = "github:xremap/nix-flake";

    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, unstable-nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = unstable-nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations = {
        idea = lib.nixosSystem {
          specialArgs = { inherit inputs pkgs-unstable; };
          modules = [
            ./idea/configuration.nix

            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.default
            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.default
            inputs.xremap-flake.nixosModules.default

            (import ./overlays)
          ];
        };
      };
    };
}
