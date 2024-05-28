{ inputs, pkgs, lib, ... }: {
  # https://hugoreeves.com/posts/2019/nix-home/
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
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
      colors.draw_bold_text_with_bright_colors = true;
    };
  };
}
