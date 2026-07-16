# Host: lucas-nixos (NixOS — placeholder, untested)
# When you have a NixOS machine:
#   1. Generate hardware-configuration.nix: nixos-generate-config
#   2. Copy it to nix/nixos/hardware-configuration.nix
#   3. Edit this file with the real hostname, username, etc.
#   4. Uncomment the nixosConfigurations line in flake.nix
{
  system = "x86_64-linux";          # change for your hardware
  username = "lucas";
  hostname = "lucas-nixos";
  homeDirectory = "/home/lucas";
  stateVersion = "24.11";           # pin to the NixOS version at install time
}
