{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  home.username = "roginski";
  home.homeDirectory = "/home/roginski";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "EyalRoginski";
    userEmail = "eyalrog1@gmail.com";
  };

  home.shellAliases = {
    python = "python3";
    ipython = "ipython3";
    cat = "bat";

    ta = "tmux attach -t";
    tal = "tmux attach";
    tls = "tmux ls";
    tn = "tmux new";
    tnc = "tmux new -c";

    # Shlafman's git aliases, now in Nix form!
    ga = "git add";
    gs = "git status";
    gd = "git diff";
    gb = "git branch";
    gcb = "git branch --show-current";
    gr = "git restore";
    gcm = "git commit -m";
    gcam = "git add . && git commit -m";
    gco = "git checkout";
    gcob = "git checkout -b";
    gcom = "git checkout main && git pull origin main";
    gpull = "git pull origin $(git branch --show-current)";
    gpush = "git push origin $(git branch --show-current)";
    gpushu = "git push origin $(git branch --show-current) --set-upstream";
  };

  home.packages = with pkgs; [
    htop
    git
    fd
    openssh
    tmux
    tree
    zsh-powerlevel10k
    gcc
    nodejs_24
    bat
    cargo
    tokei
    ripgrep
    just
    rustfmt
    alejandra
    bacon
    clippy
  ];

  programs.zsh.enable = true;
  programs.zsh.initContent = ''
    tncs() {
      tmux new -c "$1" -s "$2"
    }
    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    source ~/.p10k.zsh
  '';
  home.file.".tmux.conf".source = "${inputs.dotfiles}/shell/.tmux.conf";
  home.file.".p10k.zsh".source = "${inputs.dotfiles}/shell/.p10k.zsh";

  programs.nixvim = {
    enable = true;

    colorschemes.kanagawa.enable = true;

    globals.mapleader = " ";

    opts = {
      # Line numbers
      nu = true;
      relativenumber = true;

      # Tabs and indentation
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      smartindent = true;

      # Text display
      wrap = false;

      # Swap/backup/undo
      swapfile = false;
      backup = false;
      undodir = "${config.home.homeDirectory}/.vim/undodir";
      undofile = true;

      # Searching
      hlsearch = false;
      incsearch = true;

      # Appearance
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      colorcolumn = "100";
    };

    keymaps = [
      # --- Normal + Visual mode ---
      {
        key = ";";
        action = ":";
        mode = ["n" "v"];
        options.noremap = true;
      }

      # --- Normal mode ---

      {
        key = "gd";
        action = "<cmd> lua vim.lsp.buf.definition()<CR>";
        mode = "n";
      }

      {
        key = "gl";
        action = "<cmd>lua vim.diagnostic.open_float()<CR>";
        mode = "n";
      }

      {
        key = "<leader>pv";
        action = "<cmd>Ex<CR>";
        mode = "n";
      }

      {
        key = "<leader>w";
        action = "<cmd>up<CR>";
        mode = "n";
      }

      {
        key = "<leader>W";
        action = ''
          function()
            vim.cmd("noa up")
          end
        '';
        mode = "n";
      }

      {
        key = "<C-d>";
        action = "<C-d>zz";
        mode = "n";
      }

      {
        key = "<C-u>";
        action = "<C-u>zz";
        mode = "n";
      }

      {
        key = "n";
        action = "nzzzv";
        mode = "n";
      }

      {
        key = "N";
        action = "Nzzzv";
        mode = "n";
      }

      {
        key = "<C-k>";
        action = "<cmd>cnext<CR>zz";
        mode = "n";
      }

      {
        key = "<C-j>";
        action = "<cmd>cprev<CR>zz";
        mode = "n";
      }

      {
        key = "<leader>k";
        action = "<cmd>lnext<CR>zz";
        mode = "n";
      }

      {
        key = "<leader>j";
        action = "<cmd>lprev<CR>zz";
        mode = "n";
      }

      {
        key = "<leader>n";
        action = "<cmd>bnext<CR>zz";
        mode = "n";
      }

      {
        key = "<leader>P";
        action = "<cmd>bprev<CR>zz";
        mode = "n";
      }

      {
        key = "<leader>Y";
        action = "<cmd>PyrightSetPythonPath .venv/bin/python<CR>zz";
        mode = "n";
      }

      # --- Visual mode only ---
      {
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        mode = "v";
      }

      {
        key = "K";
        action = ":m '<-2<CR>gv=gv";
        mode = "v";
      }

      # --- Visual + Normal mode ---
      {
        key = "<leader>y";
        action = ''"+y'';
        mode = ["n" "v"];
      }

      {
        key = "<leader>d";
        action = ''"_d'';
        mode = ["n" "v"];
      }

      # --- Visual mode (x) only ---
      {
        key = "<leader>p";
        action = ''"_dP'';
        mode = "x";
      }
    ];

    plugins = {
      lexima.enable = true;

      conform-nvim.enable = true;
      conform-nvim.settings = {
        formatters_by_ft = {
          nix = ["alejandra"];
          rust = ["rustfmt"];
        };

        format_on_save = {
          lsp_format = "fallback";
          timeout_ms = 500;
        };
      };

      luasnip.enable = true;
      cmp = {
        enable = true;

        settings.sources = [
          {
            name = "nvim_lsp";
          }
          {
            name = "luasnip";
          }
          {
            name = "path";
          }
          {
            name = "buffer";
          }
        ];

        settings.mapping = {
          "<Tab>" = ''
            cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if not cmp.get_selected_entry() then
                cmp.select_next_item()
              end
              if cmp.visible() then
                cmp.confirm()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" })
          '';

          "<S-Tab>" = ''
            cmp.mapping(function(fallback)
              local luasnip = require("luasnip")
              if luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" })
          '';

          "<CR>" = ''
            cmp.mapping(function(fallback)
              if not cmp.get_selected_entry() then
                cmp.select_next_item()
              end
              if cmp.visible() then
                cmp.confirm()
                vim.api.nvim_input("<CR>")
              else
                fallback()
              end
            end, { "i", "s" })
          '';

          "<C-j>" = ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { "i", "s" })
          '';

          "<C-k>" = ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { "i", "s" })
          '';
        };
      };
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };
        };
      };

      treesitter = {
        enable = true;
        settings = {
          ensure_installed = ["python" "rust" "javascript" "java" "html" "c" "lua" "vim" "vimdoc" "query"];
          sync_install = false;
          auto_install = true;
          highlight = {
            enable = true;
            additional_vim_regex_highlighting = false;
          };
        };
      };

      telescope = {
        enable = true;

        settings.defaults = {
          mappings = {
            i = {
              "<C-j>" = "move_selection_next";
              "<C-k>" = "move_selection_previous";
            };
          };
        };

        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Find files";
          };

          "<leader>fa" = {
            action = ''
                   function()
              require("telescope.builtin").find_files({
                hidden = true,
                no_ignore = true,
                no_ignore_parent = true,
              })
                   end
            '';
            options.desc = "Find all files (including hidden and ignored)";
          };

          "<leader>fp" = {
            action = "git_files";
            options.desc = "Find Git-tracked files";
          };

          "<leader>fg" = {
            action = "live_grep";
            options.desc = "Live grep";
          };

          "<leader>fm" = {
            action = "buffers";
            options.desc = "List open buffers";
          };

          "<leader>ls" = {
            action = "lsp_document_symbols";
            options.desc = "LSP document symbols";
          };

          "<leader>la" = {
            action = "lsp_dynamic_workspace_symbols";
            options.desc = "LSP workspace symbols";
          };
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      {
        plugin = tmuxPlugins.dracula;
        extraConfig = ''
          # Dracula config
              set -g @dracula-show-powerline true
              set -g @dracula-show-left-icon session
              set -g @dracula-plugins "time git battery"
              set -g @dracula-show-timezone false
              set -g @dracula-military-time true
              set -g @dracula-show-empty-plugins false
        '';
      }
    ];
  };

  # This is required
  home.stateVersion = "24.11";
}
