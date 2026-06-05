{ config, pkgs, lib, ... }:

{
  imports = [
    ./darwin/system.nix
    ./darwin/services.nix
    ./darwin/homebrew.nix
  ];
}
