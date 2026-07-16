{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────────────────────
  # Nix-managed services (alternative to brew services)
  # ──────────────────────────────────────────────────────────────
  services = {
    # PostgreSQL — nix-darwin module needs initdb run manually, config not
    # auto-generated. Keep on brew services until nix-darwin module matures.
    # postgresql = {
    #   enable = true;
    #   package = pkgs.postgresql_14;
    # };

    # Redis — nix-darwin module doesn't generate /etc/redis.conf.
    # redis = { enable = true; };
  };
}
