# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      inputs.claude-code-nix.overlays.default

      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home.username = "roginski";
  home.homeDirectory = "/home/roginski";

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      includes = [
        {
          contents = {
            user.email = "eyalrog1@gmail.com";
            user.name = "Eyal Roginski";
          };
        }
      ];
    };

    mangohud.enable = true;
    obsidian.enable = true;
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
    gnumake
    qemu
    gdb
    nasm
    xorriso
    grub2
    ruff
    visidata
    cargo-expand
    (pkgs.python312.withPackages (ps:
      with ps; [
        ipython
        jupyterlab
      ]))
    uv
    wget
    wslu
    poetry
    pstree
    duckdb
    opencode
    unstable.antigravity-cli
    claude-code
    unstable.godot-mono
    stow
    alacritty
    atuin
    unstable.neovim
    tree-sitter
    rustc
    rust-analyzer
    clang-tools
    basedpyright
    lua-language-server
    bash-language-server
    nixd
    omnisharp-roslyn
    # The same SDK godot-mono builds with, so Godot and the LSP agree
    unstable.dotnetCorePackages.sdk_8_0-source
  ];

  # Shell, tmux and neovim config live in ~/dotfiles and are linked with GNU Stow.
  # These are the read-only pieces that config expects to find in $HOME.
  home.file = {
    ".oh-my-zsh".source = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    ".oh-my-zsh-custom/themes/powerlevel10k".source = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
    ".tmux/plugins/tpm".source = inputs.tpm;
    ".config/alacritty/themes".source = inputs.alacritty-theme;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
