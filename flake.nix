{

  description = "Davidove snežinke";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } : 
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      idea = lib.nixosSystem {
        system = "x86_64-linux";
	modules = [ 
          # sistem
          ./idea/configuration.nix 

	  # uporabniške nastavitve
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
