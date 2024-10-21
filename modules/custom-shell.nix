{ config, lib, pkgs, userInfo, ... }: {
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
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
      bindkey  '\e[H'   beginning-of-line
      bindkey  '\e[F'   end-of-line
      bindkey  '\e[3~'  delete-char
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
      cedit = "nvim -c 'cd ${userInfo.dotFiles}' ${userInfo.dotFiles}";
      cdiff = "git -C ${userInfo.dotFiles} diff";
      csave = ''
        git -C ${userInfo.dotFiles} commit -aem "$(hostname)@$(readlink /nix/var/nix/profiles/system | cut -d- -f2)"'';
      cpush = "git -C ${userInfo.dotFiles} push origin main";
      cpull = "git -C ${userInfo.dotFiles} pull origin main";
      cst = "git -C ${userInfo.dotFiles} status";
      clg = "git -C ${userInfo.dotFiles} log --oneline";
    };
  };

  programs.fzf.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    extraConfig = ''
      # pane splitting
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # alt+hjkl moves focus between panes, including vim
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h'  'select-pane -L'
      bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j'  'select-pane -D'
      bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k'  'select-pane -U'
      bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l'  'select-pane -R'
      bind-key -n 'M-\' if-shell "$is_vim" 'send-keys M-\\'  'select-pane -l'

      bind-key -T copy-mode-vi 'M-h' select-pane -L
      bind-key -T copy-mode-vi 'M-j' select-pane -D
      bind-key -T copy-mode-vi 'M-k' select-pane -U
      bind-key -T copy-mode-vi 'M-l' select-pane -R
      bind-key -T copy-mode-vi 'M-\' select-pane -l

      # unbind old bindings
      unbind-key -n 'C-h'
      unbind-key -n 'C-j'
      unbind-key -n 'C-k'
      unbind-key -n 'C-l'

      # pane resizing
      bind -r M-k resize-pane -U
      bind -r M-j resize-pane -D
      bind -r M-h resize-pane -L
      bind -r M-l resize-pane -R

      # don't rename windows automatically
      set-option -g allow-rename off

      # Start panes at 1, not 0
      setw -g pane-base-index 1

      # powerline
      set -g status-interval 1
      # set -g status-right '#(powerline tmux right)'
      # set -g status-left '#(powerline tmux left)'
    '';

    plugins = with pkgs.tmuxPlugins; [
      yank
      vim-tmux-navigator
      better-mouse-mode
    ];
  };

  # command line utilities
  home.packages = with pkgs; [
    bat
    mtr
    htop
    tree
    jq
    dig
    wget
    curl

    # powerline for tmux
    # powerline
    python311Packages.psutil
  ];
}
