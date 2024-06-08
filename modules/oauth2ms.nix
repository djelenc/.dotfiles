{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [ oauth2ms ];

  sops.secrets = {
    tenant_id = { };
    client_id = { };
    client_secret = { };
  };

  # TODO: The following cant work at compile time
  # xdg.configFile."oauth2ms/config.txt".text = ''
  #   {
  #       "tenant_id": "${builtins.readFile config.sops.secrets.tenant_id.path}",
  #       "client_id": "${builtins.readfile config.sops.secrets.client_id.path}",
  #       "client_secret": "${
  #         builtins.readfile config.sops.secrets.client_secret.path
  #       }",
  #       "redirect_host": "localhost",
  #       "redirect_port": "5000",
  #       "redirect_path": "/getToken/",
  #       "scopes": ["https://outlook.office.com/IMAP.AccessAsUser.All"]
  #   }
  # '';
}
