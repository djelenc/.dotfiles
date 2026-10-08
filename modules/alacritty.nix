{
  inputs,
  pkgs,
  lib,
  ...
}:
{
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

      env = {
        TERM = "xterm-256color";
      };

      scrolling.history = 100000;
      # Like GNOME Terminal: selection goes to PRIMARY, explicit copy to CLIPBOARD.
      selection.save_to_clipboard = false;
      keyboard.bindings = [
        # GNOME Terminal uses CLIPBOARD for Shift+Insert; Alacritty defaults to PRIMARY.
        { key = "Insert"; mods = "Shift"; action = "Paste"; }
      ];
      colors.draw_bold_text_with_bright_colors = true;
    };
  };

  xdg.terminal-exec = {
    enable = true;

    settings = {
      default = [
        "Alacritty.desktop"
      ];
    };
  };
}
