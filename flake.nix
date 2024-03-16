{
  description = "Davidov NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      follows = "hyprland-virtual-desktops/hyprland"; 
    };
    hyprland-virtual-desktops.url = "github:levnikmyskin/hyprland-virtual-desktops";
  };

  outputs = { self, nixpkgs, home-manager, hyprland-virtual-desktops, ... } : 
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      idea = lib.nixosSystem {
      	modules = [ 
	  # sys
          ./idea/configuration.nix 

          # userland
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.david = import ./idea/home.nix;
          }
        ];
      };
    };
  };
}
