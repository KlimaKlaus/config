# Disk layout for Freyr (NixOS desktop)
#
# ⚠️ EDIT THIS BEFORE USE: change `device` to match your actual disk
# Find your disk with: lsblk
# Typical: /dev/nvme0n1 (NVMe) or /dev/sda (SATA)
#
# Layout:
#   - /dev/sdX1  512MB  FAT32  EFI system partition  → /boot
#   - /dev/sdX2   16GB  Swap                        → swap
#   - /dev/sdX3   Rest   Btrfs  @root + @home       → / + /home
#
# Apply with:
#   sudo nix --experimental-features "nix-command flakes" \
#     run github:nix-community/disko/latest -- \
#     --mode disko ./nix/nixos/disk-config.nix
{
  disk = {
    main = {
      type = "disk";
      device = "/dev/sdX";  # ← CHANGE ME (e.g. /dev/nvme0n1, /dev/sda)
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "512M";
            type = "EF00";   # EFI system partition
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          swap = {
            size = "16G";
            content = {
              type = "swap";
              resumeDevice = true;  # Enable hibernation resume
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];   # Force if leftover FS
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
