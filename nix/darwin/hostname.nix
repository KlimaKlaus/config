{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "lucas-macbook-pro";
  system.primaryUser = "lucasfreytorreshanson";

  # Match the GID from the official Nix installer (350, not 30000)
  ids.gids.nixbld = 350;

  nix = {
    enable = true;
    settings = {
      trusted-users = [ "lucasfreytorreshanson" "@admin" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 3; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  system.stateVersion = 4;
}
