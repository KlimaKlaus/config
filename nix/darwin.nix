{ config, pkgs, lib, ... }:

{
  imports = [
    ./darwin/system.nix
    ./darwin/hostname.nix
    ./darwin/launchd.nix
    ./darwin/services.nix
    ./darwin/homebrew
  ];
}
