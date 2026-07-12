{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────────────────────
  # Nix-managed services (alternative to brew services)
  # ──────────────────────────────────────────────────────────────
  services = {
    # PostgreSQL — replaces brew services start postgresql@14
    # Uncomment and migrate data:
    #   1. pg_dumpall > dump.sql
    #   2. brew services stop postgresql@14
    #   3. Uncomment below + rebuild
    #   4. psql -f dump.sql
    # postgresql = {
    #   enable = true;
    #   package = pkgs.postgresql_14;
    # };

    # Redis — replaces brew services start redis
    # redis = { enable = true; };
  };
}
