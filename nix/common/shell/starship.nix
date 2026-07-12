{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    # Config is symlinked via dotfiles.nix
  };
}
