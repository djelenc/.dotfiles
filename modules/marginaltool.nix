{ config, lib, pkgs, ... }:

let
  marginaltoolSrc = pkgs.fetchgit {
    url = "https://git.fri.uni-lj.si/rc/marginaltool.git";
    rev = "5354e815595da9cee3ed571020f53d7414744791";
    sha256 = "sha256-0gty+FyHE684XxhsonwkYsN7x73H+T5xmcHl5hPiT8o=";
  };

  # Python interpreter with the modules marginaltool imports
  marginaltoolPython =
    pkgs.python3.withPackages (ps: with ps; [ ps.requests ps.tkinter ]);

  # Wrapper so "marginaltool" is a normal command in PATH
  marginaltool = pkgs.writeShellScriptBin "marginaltool" ''
    exec ${marginaltoolPython}/bin/python3 \
      ${marginaltoolSrc}/marginaltool "$@"
  '';
in {
  # 1) Make the command available
  home.packages = [ marginaltool pkgs.openssl pkgs.opensc ];

  # 2) Install the .desktop file 
  xdg.desktopEntries.marginaltool = {
    name = "marginaltool";
    exec = "marginaltool %u";
    terminal = true;
    type = "Application";
    mimeType = [ "x-scheme-handler/bc-digsign" ];
  };

  # 3) Set marginaltool as default handler for bc-digsign URLs
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/bc-digsign" = [ "marginaltool.desktop" ];
    };
  };

  # 4) Create ~/.marginaltool with the requested config
  # TODO: Move it to sops-nix
  home.file.".marginaltool".text = ''
    [https://gcsign.uni-lj.si/BCSign/]
    engine = file
    keyfile = /home/david/.pki/dj.key.pem
    certfile = /home/david/.pki/dj.cert.pem
  '';
}
