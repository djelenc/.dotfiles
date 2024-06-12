{ inputs, pkgs, lib, config, ... }: {
  options = {
    dotFilesRoot = lib.mkOption {
      # default = ''/home/david/.dotfiles'';
      type = lib.types.path;
      description = "Path to .dotfiles directory";
    };

  };

  config = {
    home.packages = with pkgs; [
      fishPlugins.bobthefisher
      fishPlugins.plugin-git
      fishPlugins.fzf-fish
    ];

    programs.fish = {
      enable = true;
      shellAliases = {
        l = "exa --hyperlink --icons";
        ll = "exa -la --icons --hyperlink --header";
        glg = "git log --oneline";
        gst = "git status";
        gdf = "git diff";
        gco = "git checkout";

        cedit = "nvim -c 'cd ${config.dotFilesRoot}' ${config.dotFilesRoot}";
        cdiff = "git -C ${config.dotFilesRoot} diff";
        csave = ''
          git -C ${config.dotFilesRoot} commit -aem "$(hostname)@$(readlink /nix/var/nix/profiles/system | cut -d- -f2)"'';
        cpush = "git -C ${config.dotFilesRoot} push origin main";
        cpull = "git -C ${config.dotFilesRoot} pull origin main";
        cst = "git -C ${config.dotFilesRoot} status";
        clg = "git -C ${config.dotFilesRoot} log --oneline";
      };

      shellInit = ''
        set -g direnv_fish_mode eval_on_arrow
        direnv hook fish | source
      '';
    };
  };
}
