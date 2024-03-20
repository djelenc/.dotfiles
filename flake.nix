{
  description = "Davidov NixOS";

  inputs = {
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      follows = "hyprland-virtual-desktops/hyprland"; 
    };

    hyprland-virtual-desktops = {
      url = "github:levnikmyskin/hyprland-virtual-desktops";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland-virtual-desktops, ... } @ inputs : 
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
