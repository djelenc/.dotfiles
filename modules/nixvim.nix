{ inputs, pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      ripgrep # req: telescope
    ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };

    plugins = {
      which-key.enable = true;
      lightline.enable = true;
      autoclose.enable = true;
      treesitter.enable = true;
      nix.enable = true;
      surround.enable = true;
      telescope = {
        enable = true;

        keymaps = {
          "<leader><leader>" = {
            action = "git_files";
            options.desc = "Telescope Git Files";
          };
          "<leader>fg" = "live_grep";
          "<leader>ff" = "find_files";
        };
      };
    };

    colorschemes.tokyonight = {
      enable = true;
      settings = { transparent = true; };
    };

    # colorschemes.gruvbox = {
    #   enable = true;
    #   settings = {
    #     transparent_mode = true;
    #   };
    # };

    autoCmd = [{
      # Delete trailing whitespace on save
      event = [ "BufWritePre" ];
      pattern = [ "*" ];
      command = ":%s/\\s\\+$//e";
    }];
    keymaps = [
      {
        key = "<A-x>";
        action = ":";
        options.desc = "Open command line";
      }
      {
        key = "<leader>j";
        action = ":bn<CR>";
        options.desc = "Next buffer";
      }
      {
        key = "<leader>k";
        action = ":bp<CR>";
        options.desc = "Previous buffer";
      }
      {
        key = "<leader>bd";
        action = ":bd<CR>";
        options.desc = "Delete buffer";
      }
      {
        key = "<leader>fs";
        action = ":w<CR>";
        options.desc = "Save buffer";
      }
      {
        key = "<leader>fS";
        action = ":wa<CR>";
        options.desc = "Save all open buffers";
      }
      {
        key = "<leader>qq";
        action = ":qa<CR>";
        options.desc = "Quit";
      }
    ];
  };
}
