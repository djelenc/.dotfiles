{ inputs, pkgs, lib, config, ... }: {
  options = {
    dotFilesRoot = lib.mkOption {
      # default = ''/home/david/.dotfiles'';
      type = lib.types.path;
      description = "Path to .dotfiles directory";
    };

  };

  config = {
    environment.systemPackages = with pkgs; [
      fishPlugins.bobthefisher
      fishPlugins.plugin-git
      fishPlugins.fzf-fish
    ];

    programs.fish = {
      enable = true;
      shellAbbrs = {
        glg = "git log --oneline";
        gst = "git status";
        gdf = "git diff";
        gco = "git checkout";

        cswitch = "sudo nixos-rebuild switch --flake ${config.dotFilesRoot}";
        ctest = "sudo nixos-rebuild test --flake ${config.dotFilesRoot}";
        cedit = "nvim -c 'cd ${config.dotFilesRoot}' ${config.dotFilesRoot}";
        cdiff = "git -C ${config.dotFilesRoot} diff";
        csave = ''
          git -C ${config.dotFilesRoot} commit -aem "$(hostname)@$(readlink /nix/var/nix/profiles/system | cut -d- -f2)"'';
        cpush = "git -C ${config.dotFilesRoot} push origin main";
        cpull = "git -C ${config.dotFilesRoot} pull origin main";
        cst = "git -C ${config.dotFilesRoot} status";
        clg = "git -C ${config.dotFilesRoot} log --oneline";
      };
    };

    users.users.david.shell = pkgs.fish;
  };
}
