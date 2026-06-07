{ config, pkgs, lib, flakeDir, ... }:

{
  home.file = {

    # ── Vault (Obsidian memory — separate git repo) ─────────────
    "vault".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Desktop/code/loki-obsidian-memory";
    ".config/starship.toml".source = "${flakeDir.outPath}/starship.toml";
    ".config/ghostty/config".source = "${flakeDir.outPath}/config.ghostty";
    ".config/lazygit/config.yml".source = "${flakeDir.outPath}/lazygit/config.yml";

    # ── Tmux ────────────────────────────────────────────────────
    ".tmux.conf".source = "${flakeDir.outPath}/.tmux.conf";
    # TPM and plugins live in ~/.tmux/plugins/ (gitignored, runtime-managed)

    # ── AeroSpace ───────────────────────────────────────────────
    ".aerospace.toml".source = "${flakeDir.outPath}/.aerospace.toml";
  };
}
