{ config, pkgs, lib, flakeDir, username, hostname, homeDirectory, stateVersion, ... }:

{
  imports = [
    ./common/packages
    ./common/shell
    ./common/git.nix
    ./common/tmux.nix
    ./common/vim.nix
    ./common/dotfiles.nix
  ];

  home = {
    username = lib.mkForce username;
    homeDirectory = lib.mkForce homeDirectory;
    stateVersion = lib.mkForce stateVersion;
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
