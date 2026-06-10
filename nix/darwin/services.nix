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
      ProgramArguments = [ "${pkgs.jankyborders}/bin/borders" ];
      KeepAlive = true;
      RunAtLoad = true;
    };
  };

  # Force-restart borders after rebuild so it reads the new bordersrc
  system.activationScripts.restartBorders.text = ''
    pkill -f borders 2>/dev/null || true
  '';
  system.stateVersion = 4;
}
