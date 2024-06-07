{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [ ripgrep ]; # required by telescope

  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

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

    colorschemes.gruvbox = {
      enable = true;
      settings.transparent_mode = true;
    };

    plugins = {
      which-key.enable = true;
      lightline.enable = true;
      commentary.enable = true;
      autoclose.enable = true;
      treesitter = {
        enable = true;
        incrementalSelection.enable = true; # gnn: grn | grm
      };
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

      refactoring = {
        enable = true;
        # enableTelescope = true;
      };
    };

    keymaps = [
      {
        key = "<A-x>";
        action = ":";
        options.desc = "Open command line";
      }
      # code refactoring
      {
        key = "<leader>cr";
        action = "<cmd>lua vim.lsp.buf.rename()<CR>";
        mode = [ "n" ];
        options.desc = "Rename variable";
      }
      {
        key = "<leader>ce";
        action = ":Refactor extract";
        mode = [ "v" ];
        options.desc = "Extract function";
      }
      {
        key = "<leader>cf";
        mode = [ "v" ];
        action = ":Refactor extract_to_file";
        options.desc = "Extract function to file";
      }
      {
        key = "<leader>cv";
        mode = [ "v" ];
        action = ":Refactor extract_var";
        options.desc = "Extract variable";
      }
      {
        key = "<leader>ci";
        action = ":Refactor inline_var";
        mode = [ "n" "v" ];
        options.desc = "Inline variable";
      }
      {
        key = "<leader>cI";
        mode = [ "n" ];
        action = ":Refactor inline_func";
        options.desc = "Inline function";
      }
      {
        key = "<leader>cb";
        mode = [ "n" ];
        action = ":Refactor extract_block";
        options.desc = "Extract block";
      }
      {
        key = "<leader>cbf";
        mode = [ "n" ];
        action = ":Refactor extract_block_to_file";
        options.desc = "Extract block to file";
      }
      # moving lines
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

    autoCmd = [{
      # Delete trailing whitespace on save
      event = [ "BufWritePre" ];
      pattern = [ "*" ];
      command = ":%s/\\s\\+$//e";
    }];
  };
}
