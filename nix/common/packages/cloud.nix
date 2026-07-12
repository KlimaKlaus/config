{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    azure-cli
    yubikey-manager
    tailscale
  ];
}
