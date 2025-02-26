{
  description = "Davidov NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-24_05.url = "github:nixos/nixpkgs/nixos-24.05";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    xremap-flake.url = "github:xremap/nix-flake";

    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, nixpkgs-24_05, home-manager, ... }@inputs:
    let
      userInfo = {
        name = "David";
        user = "david";
        fullName = "David Jelenc";
        email = "david.jelenc@fri.uni-lj.si";
        dotFiles = "/home/david/.dotfiles";
      };
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-24_05 = nixpkgs-24_05.legacyPackages.${system};

    in {
      nixosConfigurations = {
        idea = lib.nixosSystem {
          specialArgs = { inherit inputs userInfo pkgs-24_05; };
          modules = [
            ./idea/configuration.nix

            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.default
            inputs.xremap-flake.nixosModules.default

            (import ./overlays)
          ];
        };
      };
    };
}
