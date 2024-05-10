{ config, lib, pkgs, ... }:
let
  # mbsync with explicit XOATH2 support
  # https://github.com/NixOS/nixpkgs/issues/108480#issuecomment-1115108802
  isync-oauth2 = with pkgs;
    buildEnv {
      name = "isync-oauth2";
      paths = [ isync ];
      pathsToLink = [ "/bin" ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram "$out/bin/mbsync" \
          --prefix SASL_PATH : "${cyrus_sasl}/lib/sasl2:${cyrus-sasl-xoauth2}/lib/sasl2"
      '';
    };
in {
  home.packages = with pkgs; [
    # doom emacs utils
    ripgrep
    coreutils
    fd
    clang
    shellcheck
    graphviz
    shfmt
    imagemagick
    pandoc

    # email related
    oauth2ms
    cyrus_sasl
    cyrus-sasl-xoauth2
    isync-oauth2
  ];

  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk; # supports fractional scaling
      extraPackages = (epkgs: [ pkgs.mu.mu4e epkgs.mu4e ]);
      overrides = self: super: { org = self.elpaPackages.org; };
    };

    mu.enable = true;
    msmtp.enable = true;
    mbsync.enable = true;
    mbsync.package = isync-oauth2;
  };

  accounts.email.accounts.fri = rec {
    primary = true;
    flavor = "outlook.office365.com";
    realName = "David Jelenc";
    userName = "davidjelenc@fri1.uni-lj.si";
    address = "david.jelenc@fri.uni-lj.si";
    passwordCommand = "oauth2ms";

    mbsync = {
      enable = true;
      create = "both";
      expunge = "both";
      patterns = [
        "Archive"
        "Drafts"
        "Deleted Items"
        "Inbox"
        "Junk Email"
        "Sent Email"
      ];
      extraConfig.account.AuthMechs = "XOAUTH2";
    };

    msmtp = {
      enable = true;
      extraConfig.auth = "xoauth2";
      extraConfig.passwordeval = "oauth2ms";
    };

    mu.enable = true;
  };
}