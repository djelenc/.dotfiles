{
  description = "Davidov NixOS";

  inputs = {
    nixpkgs = { url = "nixpkgs/nixos-unstable"; };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      # url = "github:hyprwm/Hyprland";
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
      pkgs = nixpkgs.legacyPackages.${system}; # .extend (final: prev: {
      #   msmtp = prev.msmtp.overrideAttrs (old: {
      #     src = prev.fetchFromGitHub {
      #       wner = "marlam";
      #       repo = "msmtp-mirror";
      #       rev = "msmtp-1.8.26";
      #       hash = "";
      #     };
      #   });
      # });
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
