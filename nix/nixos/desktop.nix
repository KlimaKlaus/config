# Desktop — X11 Openbox for Freyr
# Hyprland/Wayland disabled: NVIDIA 580 open kernel driver crash
#
# GPU layout (from nvidia-smi):
#   GPU 0 (bus 23:00.0) = RTX 3070 (8GB)     — monitor on DP-1, Weston/SDDM
#   GPU 1 (bus 2D:00.0) = RTX 5070 Ti (16GB) — headless compute
#
# Service mapping: see nix/nixos/gpu/default.nix and nix/common/services/gpu-services.nix

{ config, pkgs, lib, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;

  # Openbox window manager
  services.xserver.windowManager.openbox.enable = true;

  # NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  # Key packages
  environment.systemPackages = with pkgs; [
    firefox
    wezterm
    neovim
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    tint2
    wofi
    dunst
    libnotify
    nemo
    nemo-fileroller
    pavucontrol
    networkmanagerapplet
    noto-fonts
    noto-fonts-color-emoji
    xfce.thunar
    xterm
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "FiraCode Nerd Font" ];
    sansSerif = [ "Noto Sans" ];
    emoji = [ "Noto Color Emoji" ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = false;
  services.printing.enable = false;
}
