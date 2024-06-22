{ config, lib, pkgs, ... }:
let dotFilesRoot = "/home/david/.dotfiles";
in {
  programs.eza = {
    enable = true;
    git = true;
    icons = true;
  };

  programs.starship.enable = true;

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    defaultKeymap = "emacs";

    completionInit = ''
      # default
      autoload -U compinit && compinit

      # C-w and M-d delete only to the first /
      autoload -U select-word-style
      select-word-style bash

      # case-insensitive tab-completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      # highlight tab-completed entry
      zstyle ':completion:*' menu select

      # key bindings
      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line
      bindkey  "^[[3~"  delete-char
    '';

    shellAliases = {
      # tmux
      tm = " tmux new-session -A -s"; # create/attach
      tk = "tmux kill-session -t"; # kill
      tl = "tmux list-sessions"; # list all

      # the usual ls-ing with exa
      l = "exa --icons --hyperlink"; # basic
      ll = "exa -la --icons --hyperlink --git --header"; # details
      lt = "exa --icons --tree --hyperlink"; # tree

      # git
      glg = "git log --oneline";
      gst = "git status";
      gdf = "git diff";
      gco = "git checkout";

      # managing nixos configuration
      cedit = "nvim -c 'cd ${dotFilesRoot}' ${dotFilesRoot}";
      cdiff = "git -C ${dotFilesRoot} diff";
      csave = ''
        git -C ${dotFilesRoot} commit -aem "$(hostname)@$(readlink /nix/var/nix/profiles/system | cut -d- -f2)"'';
      cpush = "git -C ${dotFilesRoot} push origin main";
      cpull = "git -C ${dotFilesRoot} pull origin main";
      cst = "git -C ${dotFilesRoot} status";
      clg = "git -C ${dotFilesRoot} log --oneline";
    };
  };

  programs.fzf.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = ''
      # remap prefix from 'C-b' to 'C-a'
      unbind C-b
      set-option -g prefix C-w
      bind-key C-w send-prefix

      # remove the default ESC delay
      set -sg escape-time 2

      # split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # vim-like pane resizing
      bind -r C-k resize-pane -U
      bind -r C-j resize-pane -D
      bind -r C-h resize-pane -L
      bind -r C-l resize-pane -R

      # vim-like pane switching
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R

      # Enable mouse mode (tmux 2.1 and above)
      set -g mouse on

      # don't rename windows automatically
      set-option -g allow-rename off

      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
    '';

    plugins = with pkgs.tmuxPlugins; [ yank vim-tmux-navigator ];
  };
}
