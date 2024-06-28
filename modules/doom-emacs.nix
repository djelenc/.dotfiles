{ config, lib, pkgs, userInfo, ... }:
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
  # links doom config; has to be absolute, otherwise it becomes read-only
  home.file.".doom.d".source =
    config.lib.file.mkOutOfStoreSymlink userInfo.dotFiles + /doom-emacs;

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

    # doom-web module
    html-tidy
    stylelint
    jsbeautifier

    # email related
    cyrus_sasl
    cyrus-sasl-xoauth2
    isync-oauth2
    oauth2ms
    (import ../scripts/maildir-timestamp-fix.nix { inherit pkgs; })

    # dictionaries
    (aspellWithDicts (dicts: with dicts; [ sl en en-computers en-science ]))
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

  accounts.email = {

    maildirBasePath = ".mail";

    accounts.fri = rec {
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
          # `mbsync -l <account>` to see which folders sync
          "Archive"
          "Deleted Items"
          "Drafts"
          "INBOX"
          "Junk Email"
          "Sent Items"
        ];
        extraConfig.account.AuthMechs = "XOAUTH2";
        extraConfig.channel.CopyArrivalDate = "yes";
      };

      msmtp = {
        enable = true;
        extraConfig.auth = "xoauth2";
        extraConfig.passwordeval = "oauth2ms";
      };

      mu.enable = true;
    };

    # accounts.gmail = rec {
    #   flavor = "gmail.com";
    #   realName = "David Jelenc";
    #   userName = "djelenc.fri";
    #   address = "djelenc.fri@gmail.com";
    #   passwordCommand = "cat /home/david/.certs/gmail.pass";

    #   mbsync = {
    #     enable = true;
    #     create = "maildir";
    #     expunge = "maildir";
    #     patterns = [ "*" ];
    #     extraConfig.account.AuthMechs = "LOGIN";
    #     extraConfig.channel.CopyArrivalDate = "yes";
    #   };

    #   msmtp.enable = true;
    #   mu.enable = true;
    # };
  };
}
