{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # ── Hostname (must match the darwinConfigurations key) ────────
  networking.hostName = "lucas-macbook-pro";

  # ── Primary user (required by nix-darwin for defaults) ──────
  system.primaryUser = "lucasfreytorreshanson";

  # Match the GID from the official Nix installer (350, not 30000)
  ids.gids.nixbld = 350;

  # ── Nix daemon config ─────────────────────────────────────────
  nix = {
    enable = true;
    settings = {
      trusted-users = [ "lucasfreytorreshanson" "@admin" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 3; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  # ── System packages (system-level, not user) ──────────────────
  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # ── Services (formerly brew services) ─────────────────────────
  services = {
    # PostgreSQL — replaces brew services start postgresql@14
    # TODO: uncomment and migrate data (see MIGRATION.md step 3.5)
    # postgresql = {
    #   enable = true;
    #   package = pkgs.postgresql_14;
    # };

    # Redis — replaces brew services start redis
    # TODO: uncomment if migrating
    # redis = {
    #   enable = true;
    # };
  };

  launchd.user.agents.borders = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "style=round"
        "width=8.0"
        "active_color=0xff74c7ec"
        "inactive_color=0xffcba6f7"
        "hidpi=on"
      ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };

  # Clean up leaked Tailwind CSS v4 oxide-helper processes
  # Known bug: tailwindcss-language-server spawns oxide-helper workers
  # that accumulate over time and never terminate (~25 MB each).
  # If >20 are detected, kill the parent LSP; Zed restarts it cleanly.
  launchd.user.agents.tailwind-cleanup = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "-c"
        ''
          count=$(pgrep -c -f oxide-helper.js 2>/dev/null || echo 0)
          if [ "$count" -gt 20 ]; then
            parent=$(pgrep -f tailwindcss-language-server 2>/dev/null | head -1)
            if [ -n "$parent" ]; then
              kill "$parent" 2>/dev/null
              logger -t tailwind-cleanup "Killed tailwindcss-language-server (PID $parent) — $count oxide-helper workers leaked"
            fi
          fi
        ''
      ];
      StartInterval = 1800;
      RunAtLoad = true;
      StandardOutPath = "/tmp/tailwind-cleanup.out";
      StandardErrorPath = "/tmp/tailwind-cleanup.err";
    };
  };
  system.stateVersion = 4;
}
