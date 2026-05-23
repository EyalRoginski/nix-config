{
  description = "Roginski's Nix Config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles.url = "github:EyalRoginski/dotfiles";
    dotfiles.flake = false;

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    ...
  } @ inputs: let
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        # > Our main nixos configuration file <
        modules = [./nixos/configuration.nix];
      };

      wsl = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./nixos/wsl-configuration.nix
          nixos-wsl.nixosModules.default
          # inputs.home-manager.nixosModules.home-manager
          # {
          #   home-manager.extraSpecialArgs = {inherit inputs nixpkgs;};
          # }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "roginski@nixos" = home-manager.lib.homeManagerConfiguration {
        # Home-manager requires 'pkgs' instance
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        # > Our main home-manager configuration file <
        modules = [./home-manager/home.nix];
      };
    };
  };
}
