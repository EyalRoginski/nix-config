{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles.url = "github:EyalRoginski/dotfiles";
    dotfiles.flake = false;

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    ...
  } @ inputs: {
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        nixos-wsl.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = {inherit inputs nixpkgs;};
        }
      ];
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    };

    homeConfigurations."roginski" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = [
        ./home.nix # Assuming your Home Manager configuration is in home.nix
      ];
      # specialArgs = { inherit inputs nixpkgs; };
      extraSpecialArgs = {inherit inputs nixpkgs;};
    };
  };
}
