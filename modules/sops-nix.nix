{ config, lib, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [ sops age ssh-to-age ];

  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  # secrets
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/home/david/.config/sops/age/keys.txt";
      generateKey = true;
    };

    secrets = {
      example_key = { };
      # example_array = { };
    };
  };
}
