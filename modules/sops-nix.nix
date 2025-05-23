{ config, lib, pkgs, inputs, userInfo, ... }:
let
  path = "/home/${userInfo.user}/.config/sops/age";
  file = "keys.txt";
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [ sops age ssh-to-age ];

  home-manager.users.${userInfo.user}.home.activation = {
    # TODO Generates an AGE key from SSH ED25519 key
    # generateConfigFile =
    #   home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #     mkdir -p ${path}
    #       ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /home/${userInfo.user}/.ssh/id_ed25519 > ${path}/${file}
    #   '';

    # # TODO: delete keys when module is deactivated
    # cleanupConfigFile = lib.hm.dag.entryAfter [ "cleanup" ] "rm -rf ${path}";
  };

  # secrets
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "${path}/${file}";
      # generateKey = true;
    };

    # decrypts and loads moss id (needed in scripts/moss.nix)
    secrets.moss_id = { };

    # open_ai token
    secrets.open_ai_test.owner = userInfo.user;
  };
}
