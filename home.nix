{ config, pkgs, inputs, ... }:

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
    zsh-powerlevel10k
  ];

  programs.zsh.enable = true;
  programs.zsh.initContent = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme\nsource ~/.p10k.zsh";
  home.file.".tmux.conf".source = "${inputs.dotfiles}/shell/.tmux.conf";
  home.file.".p10k.zsh".source = "${inputs.dotfiles}/shell/.p10k.zsh";


  # You can define dotfiles like this
  home.file.".config/nvim/init.vim".text = ''
    set number
    syntax on
  '';

  # This is required
  home.stateVersion = "24.11";
}
