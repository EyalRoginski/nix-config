{ config, pkgs, ... }:

{
  home.username = "roginski";
  home.homeDirectory = "/home/roginski";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "EyalRoginski";
    userEmail = "eyalrog1@gmail.com";
  };


  home.packages = with pkgs; [
    htop
    git
    fd
    neovim
    openssh
    tmux
    tree
  ];

  home.file.".tmux.conf".source = ./dotfiles/shell/.tmux.conf;

  # You can define dotfiles like this
  home.file.".config/nvim/init.vim".text = ''
    set number
    syntax on
  '';

  # This is required
  home.stateVersion = "24.11";
}
