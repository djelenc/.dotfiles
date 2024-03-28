{ inputs, pkgs, ... } :
{
  environment.systemPackages = with pkgs; [
    fishPlugins.bobthefisher fishPlugins.plugin-git fishPlugins.fzf-fish
  ];

  programs.fish = {
    enable = true;
    shellAbbrs = {
      glg = "git log --oneline";
      gst = "git status";
      gdf = "git diff";
      gco = "git checkout";

      # configuration management
      cswitch = "sudo nixos-rebuild switch --flake /home/david/.dotfiles/flake.nix";
      ctest = "sudo nixos-rebuild test --flake /home/david/.dotfiles/flake.nix";
      cedit = "nvim -c 'cd /home/david/.dotfiles' /home/david/.dotfiles/flake.nix";
      cdiff = "git -C /home/david/.dotfiles/ diff";
      csave = ''git -C /home/david/.dotfiles/ commit -aem "$(hostname)@$(readlink /nix/var/nix/profiles/system | cut -d- -f2)"'';
      cpush = "git -C /home/david/.dotfiles/ push origin main";
      cpull = "git -C /home/david/.dotfiles/ pull origin main";
      cst = "git -C /home/david/.dotfiles/ status";
      clg = "git -C /home/david/.dotfiles/ log --oneline";
    };
  };

  users.users.david = {
    shell = pkgs.fish;
  };
}
