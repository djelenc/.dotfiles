{ inputs, pkgs, ... }: {
  # https://hugoreeves.com/posts/2019/nix-home/
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.75;
        blur = true;
        padding = {
          x = 5;
          y = 5;
        };
        dynamic_padding = true;
      };

      env = { TERM = "xterm-256color"; };

      scrolling.history = 100000;

      font = {
        normal = {
          family = "CaskaydiaMono Nerd Font";
          style = "Regular";
        };
        size = 17.0;
      };
    };
  };
}
