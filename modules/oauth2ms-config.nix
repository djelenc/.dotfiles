{ config, lib, pkgs, userInfo, ... }: {
  # Generates a ~/.config/oauth2ms/config.json file with secrets
  #
  # Ideall, this would be a home-manager module not a nixOS module (as it is now).
  # However, templates do not yet work in home manager:
  #   https://github.com/Mic92/sops-nix/issues/423

  # read secrets
  sops.secrets = {
    tenant_id = { };
    client_id = { };
    client_secret = { };
  };

  sops.templates."oauth2ms/config.json" = { # just a name
    owner = userInfo.user;
    # actual location
    path = "/home/${userInfo.user}/.config/oauth2ms/config.json";
    content = builtins.toJSON {
      tenant_id = config.sops.placeholder.tenant_id;
      client_id = config.sops.placeholder.client_id;
      client_secret = config.sops.placeholder.client_secret;
      redirect_host = "localhost";
      redirect_port = "5000";
      redirect_path = "/getToken/";
      scopes = [ "https://outlook.office.com/IMAP.AccessAsUser.All" ];
    };
  };
}
