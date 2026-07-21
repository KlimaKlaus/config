# NixOS system modules — imports nixos/ submodules and hardware config.
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./desktop.nix
  ];

  # ── Bootloader ────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Force script-based initrd — systemd initrd breaks /sysroot mount
  # Emergency access for debugging boot failures
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.emergencyAccess = true;

  # ── NVIDIA GPU ─────────────────────────────────────────────────
  services.xserver.videoDrivers = [ "nvidia" ];
  services.displayManager.sddm.wayland.enable = false;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };


  # ── VFIO (second GPU passthrough) ──────────────────────────────

  # CUDA toolkit for LLM workloads
  environment.systemPackages = with pkgs; [
    cudaPackages.cuda_nvcc
    cudaPackages.cudnn
  ];


  # ── Networking ─────────────────────────────────────────────────
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime.offload.enable = false;
    prime.offload.enableOffloadCmd = false;
  };
  hardware.nvidia-container-toolkit.enable = true;
  boot.blacklistedKernelModules = [ "nouveau" ];
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  services.tailscale.enable = true;

  # ── Time & Locale ──────────────────────────────────────────────
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_DK.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dk";
  };

  services.xserver.xkb = {
    layout = "dk";
    variant = "";
    options = "compose:rctrl";
  };

  # ── User ───────────────────────────────────────────────────────
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # ── Docker ─────────────────────────────────────────────────────
  virtualisation.docker = {
    enable = true;
    enableNvidia = false;
    rootless.enable = false;
    rootless.setSocketVariable = false;
    daemon.settings.features.buildkit = true;
  };

  # ── SSH ────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Firmware / State ───────────────────────────────────────────
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.05";
}
