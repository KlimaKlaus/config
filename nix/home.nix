{ config, pkgs, lib, flakeDir, ... }:

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
    username = lib.mkForce "lucasfreytorreshanson";
    homeDirectory = lib.mkForce "/Users/lucasfreytorreshanson";
    stateVersion = "24.11";
  };

  # ── Fix ~/.nix-profile link (new nix CLI vs home-manager mismatch) ──
  home.activation.linkNixProfile = lib.hm.dag.entryAfter ["linkGeneration"] ''
    rm -f "$HOME/.nix-profile"
    ln -sf ${config.home.path} "$HOME/.nix-profile"
  '';

  # ── Symlink OpenWhispr.app → ~/Applications ──
  home.activation.installOpenWhispr = lib.hm.dag.entryAfter ["linkGeneration"] ''
    app_src="${pkgs.callPackage ./packages/openwhispr.nix { }}/Applications/OpenWhispr.app"
    app_dst="$HOME/Applications/OpenWhispr.app"
    mkdir -p "$HOME/Applications"
    chmod -R u+w "$app_dst" 2>/dev/null || true
    rm -rf "$app_dst"
    cp -R "$app_src" "$app_dst"
    chmod -R u+w "$app_dst"
    # Strip broken signature — Nix extraction invalidated it
    find "$app_dst" -name _CodeSignature -type d -exec rm -rf {} + 2>/dev/null || true
    find "$app_dst" -name CodeResources -type f -delete 2>/dev/null || true
    # Fix epoch timestamps from Nix store
    find "$app_dst" -exec touch -h {} +
    # Ad-hoc re-sign so new signature seals current state
    /usr/bin/codesign --force --deep --sign - "$app_dst"
    xattr -dr com.apple.quarantine "$app_dst" 2>/dev/null || true
  '';

  programs.home-manager.enable = true;

  # Allow unfree packages (slack, etc.)
  nixpkgs.config.allowUnfree = true;
}
