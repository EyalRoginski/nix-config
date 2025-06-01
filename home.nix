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
    gcc
    nodejs_24
  ];

  programs.zsh.enable = true;
  programs.zsh.initContent = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme\nsource ~/.p10k.zsh";
  home.file.".tmux.conf".source = "${inputs.dotfiles}/shell/.tmux.conf";
  home.file.".p10k.zsh".source = "${inputs.dotfiles}/shell/.p10k.zsh";

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

  home.file.".config/nvim".source = "${inputs.dotfiles}/nvim/.config/nvim";

  # This is required
  home.stateVersion = "24.11";
}
