{
  description = "lucasfreytorreshanson's macOS Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }: let
    username = "lucasfreytorreshanson";
    system = "aarch64-darwin";
  in {
    darwinConfigurations."lucas-macbook-pro" = darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ./nix/darwin.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.config.allowUnfree = true;
          home-manager.backupFileExtension = "before-nix";
          home-manager.extraSpecialArgs = { flakeDir = self; };
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./nix/home.nix;
        }
      ];
    };
  };
}
