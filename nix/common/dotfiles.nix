{ config, pkgs, lib, flakeDir, ... }:

{
  home.file = {

    # ── Vault (Obsidian memory — separate git repo) ─────────────
    "vault".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Desktop/code/loki-obsidian-memory";

    # ── Cross-platform dotfiles ─────────────────────────────────
    ".config/starship.toml".source = "${flakeDir.outPath}/starship.toml";
    ".config/ghostty/config".source = "${flakeDir.outPath}/config.ghostty";
    ".config/lazygit/config.yml".source = "${flakeDir.outPath}/lazygit/config.yml";
    ".tmux.conf".source = "${flakeDir.outPath}/.tmux.conf";
    ".config/zed/settings.json".source = "${flakeDir.outPath}/zed/settings.json";

    # ── config-add helper (cross-platform) ────────────────────
    ".local/bin/config-add".source = "${flakeDir.outPath}/scripts/config-add";

  } // lib.optionalAttrs pkgs.stdenv.isDarwin {

    # ── macOS-only dotfiles ─────────────────────────────────────
    ".aerospace.toml".source = "${flakeDir.outPath}/.aerospace.toml";
    "Library/Application Support/sioyek/prefs_user.config".source = "${flakeDir.outPath}/sioyek/prefs_user.config";
    "Library/Application Support/com.raycast.macos/Extensions/invert-scroll.applescript".source = "${flakeDir.outPath}/raycast-scripts/invert-scroll.applescript";

    # ── Raycast Script Commands ───────────────────────────────────
    ".local/share/raycast-scripts/ask-huginn.sh".source = "${flakeDir.outPath}/raycast-scripts/ask-huginn.sh";
    ".local/share/raycast-scripts/invert-scroll.applescript".source = "${flakeDir.outPath}/raycast-scripts/invert-scroll.applescript";

    # ── btop ────────────────────────────────────────────────────
    ".config/btop/btop.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/config/btop/btop.conf";
    ".config/btop/themes/catppuccin_mocha.theme".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/config/btop/themes/catppuccin_mocha.theme";

  };
}
