{ inputs, pkgs, ... } :
{

  environment.systemPackages = with pkgs; [
    ripgrep # required by telescope
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    globals.mapleader = " ";

    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };

    plugins = {
      lightline.enable = true;
      autoclose.enable = true;
      emmet.enable = true;
      treesitter.enable = true;
      nix.enable = true;
      noice.enable = true;
      surround.enable = true;
      telescope = {
        enable = true;
        keymaps = {
          "<leader><leader>" = {
            action = "git_files";
            desc = "Telescope Git Files";
          };
          "<leader>fg" = "live_grep";
          "<leader>ff" = "find_files";
        };
      };
    };

    colorschemes.tokyonight = {
      enable = true;
      transparent = true;
    };

    # colorschemes.gruvbox = {
    #   enable = true;
    #   settings = {
    #     transparent_mode = true;
    #   };
    # };

    autoCmd = [
      {
        # Delete trailing whitespace on save
        event = [ "BufWritePre"];
        pattern = [ "*" ];
        command = '':%s/\s\+$//e'';
      }
    ];
  };
}
