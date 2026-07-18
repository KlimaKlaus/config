# NixOS system modules — imports nixos/ submodules and hardware config.
#
# BEFORE FIRST BUILD:
#   1. Install NixOS and generate hardware config:
#      nixos-generate-config --root /mnt
#   2. Copy the result to this repo BEFORE building:
#      cp /mnt/etc/nixos/hardware-configuration.nix nix/nixos/hardware-configuration.nix
#   3. Verify boot device, filesystem UUIDs, and kernel modules look right
#   4. Run: nixos-rebuild switch --flake ~/config#freyr
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix  # Auto-generated — MUST exist before first build
  ];

  # ── Bootloader ────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── NVIDIA GPU ─────────────────────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Needed for some CUDA-accelerated libs
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;   # Disable if causing instability
    powerManagement.finegrained = false;
    open = false;                     # Use proprietary driver (better CUDA perf)
    nvidiaSettings = true;            # Install nvidia-settings GUI tool
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Prime (only needed for hybrid Intel/NVIDIA laptops — disable for desktop)
    prime = {
      offload = {
        enable = false;
        enableOffloadCmd = false;
      };
    };
  };

  # CUDA toolkit for LLM workloads (llama.cpp, PyTorch, etc.)
  environment.systemPackages = with pkgs; [
    cudaPackages.cuda_nvcc
    cudaPackages.cudnn
    cudaPackages.cutensor
  ];

  # Container runtime for Docker GPU passthrough
  hardware.nvidia-container-toolkit.enable = true;

  # ── Networking ─────────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Time & Locale ──────────────────────────────────────────────
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dk";
  };

  # ── User ───────────────────────────────────────────────────────
  # Home-manager creates the user's home environment; this ensures the
  # system user exists with the right groups.
  users.users.lucas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # ── Nix settings ───────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [
      "https://cache.nvidia.com"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-substituters = [
      "https://cache.nvidia.com"
      "https://nix-community.cachix.org"
    ];
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ── Docker ─────────────────────────────────────────────────────
  virtualisation.docker = {
    enable = true;
    # Use NVIDIA container toolkit for GPU-accelerated containers
    enableNvidia = true;
    # Rootless is more secure; rootful is simpler for GPU passthrough
    rootless = {
      enable = false;
      setSocketVariable = false;
    };
    daemon.settings = {
      # Allow containers to use NVIDIA GPUs
      features = { buildkit = true; };
    };
  };

  # ── SSH ────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Firmware ───────────────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;

  # ── State version ──────────────────────────────────────────────
  system.stateVersion = "25.05";  # Don't change after first build
}
