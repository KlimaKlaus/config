# NixOS system modules — placeholder.
# When setting up a NixOS machine:
#   1. Generate: nixos-generate-config --root /mnt
#   2. Copy /mnt/etc/nixos/hardware-configuration.nix → ./hardware-configuration.nix
#   3. Import it here: ./hardware-configuration.nix
#   4. Fill in boot, networking, filesystems below
{ config, pkgs, lib, ... }:

{
  # ── Placeholder — replace with real config ──────────────────

  # Bootloader (pick one):
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";

  # Networking:
  # networking.hostName = "lucas-nixos";  # set in flake.nix
  # networking.networkmanager.enable = true;

  # Time zone:
  # time.timeZone = "Europe/Copenhagen";

  # Locale:
  # i18n.defaultLocale = "en_DK.UTF-8";

  # User (created by home-manager, but ensure base user exists):
  # users.users.lucas = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" "docker" ];
  # };

  # Enable Flakes:
  # nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # State version (pin at install time):
  # system.stateVersion = "24.11";
}
