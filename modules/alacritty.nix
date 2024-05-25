{ inputs, pkgs, lib, ... }: {
  # https://hugoreeves.com/posts/2019/nix-home/
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = lib.mkDefault 0.75;
        blur = true;
        padding = {
          x = 10;
          y = 10;
        };
        dynamic_padding = true;
      };

      env = { TERM = "xterm-256color"; };

      scrolling.history = 100000;
      selection.save_to_clipboard = true;

      font = {
        normal = {
          family = lib.mkDefault "CaskaydiaMono Nerd Font";
          style = lib.mkDefault "Regular";
        };
        size = lib.mkDefault 17.0;
      };

      colors.draw_bold_text_with_bright_colors = true;
    };
  };
}
