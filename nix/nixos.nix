# NixOS entry module — imports nixos/ submodules.
# This is the NixOS counterpart to darwin.nix.
# Uncomment the nixosConfigurations line in flake.nix to activate.
{ config, pkgs, lib, ... }:

{
  imports = [
    ./nixos
  ];
}
