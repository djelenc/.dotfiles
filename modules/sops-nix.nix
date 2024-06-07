{ config, lib, pkgs, inputs, ... }:
let
  path = "${config.xdg.configHome}/sops/age";
  file = "keys.txt";
in {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home.packages = with pkgs; [ sops age ssh-to-age ];

  home.activation = {
    # Generates an AGE key from SSH ED25519 key
    generateConfigFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${path}
      ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /home/david/.ssh/id_ed25519 > ${path}/${file}
    '';

    # TODO: does not work for removals
    cleanupConfigFile = lib.hm.dag.entryAfter [ "cleanup" ] ''
      rm -rf ${path}
    '';
  };

  # secrets
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "${path}/${file}";
      generateKey = true;
    };

    secrets = {
      example_key = { };
      # example_array = { };
    };
  };
}
