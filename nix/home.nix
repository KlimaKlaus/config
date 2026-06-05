{ config, pkgs, lib, flakeDir, ... }:

{
  imports = [
    ./home/packages.nix
    ./home/shell.nix
    ./home/git.nix
    ./home/tmux.nix
    ./home/dotfiles.nix
  ];

  home = {
    username = lib.mkForce "lucasfreytorreshanson";
    homeDirectory = lib.mkForce "/Users/lucasfreytorreshanson";
    stateVersion = "24.11";
  };

  # ── Fix ~/.nix-profile link (new nix CLI vs home-manager mismatch) ──
  home.activation.linkNixProfile = lib.hm.dag.entryAfter ["linkGeneration"] ''
    rm -f "$HOME/.nix-profile"
    ln -sf ${config.home.path} "$HOME/.nix-profile"
  '';

  programs.home-manager.enable = true;

  # Allow unfree packages (slack, etc.)
  nixpkgs.config.allowUnfree = true;
}
