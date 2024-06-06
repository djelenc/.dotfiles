{ inputs, pkgs, ... }: {
  home.packages = with pkgs;
    [
      ripgrep # req: telescope
    ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    globals.mapleader = " ";

    # use system clipboard
    clipboard.register = "unnamedplus";

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };

    plugins = {
      which-key.enable = true;
      lightline.enable = true;
      commentary.enable = true;
      autoclose.enable = true;
      treesitter.enable = true;
      nix.enable = true;
      surround.enable = true;

      neo-tree = {
        enable = true;
        enableGitStatus = true;
        enableModifiedMarkers = true;
      };

      telescope = {
        enable = true;

        keymaps = {
          "<leader><leader>" = {
            action = "git_files";
            options.desc = "Telescope Git Files";
          };
          "<leader>/" = "live_grep";
          "<leader>ff" = "find_files";
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "luasnip"; }
        ];
        settings.mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };

        settings.preselect = "cmp.PreselectMode.Item";
      };

      lsp = {
        enable = true;
        servers = { pyright.enable = true; };
        keymaps.lspBuf = {
          K = "hover";
          gD = "references";
          gd = "definition";
          gi = "implementation";
          gt = "type_definition";
        };
      };
    };

    colorschemes.gruvbox = {
      enable = true;
      settings.transparent_mode = true;
    };

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
      # moving (selected) lines up/down
      {
        key = "<M-k>";
        action = ":move-2<CR>==";
      }
      {
        key = "<M-k>";
        mode = [ "v" ];
        action = ":move'<-2<CR>gv=gv";
      }
      {
        key = "<M-j>";
        action = ":move+<CR>==";
      }
      {
        key = "<M-j>";
        mode = [ "v" ];
        action = ":move'>+1<CR>gv=gv";
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
      {
        key = "<leader>op";
        action = ":Neotree toggle<CR>";
        options.desc = "Neotree";
      }
    ];
  };
}
