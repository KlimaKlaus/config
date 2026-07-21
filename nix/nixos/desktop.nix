# Desktop environment — Hyprland (Wayland tiling compositor)
#
# Hyprland is the Linux equivalent of AeroSpace on macOS: a polished,
# dynamic tiling compositor that stays out of your way. Lightweight
# enough for a dev/LLM machine, customizable enough to match the
# Catppuccin theme used across the rest of this config.
#
# Apps included:
#   - SDDM     — login/display manager
#   - Waybar   — status bar (workspace indicators, clock, system tray)
#   - Wofi     — app launcher (like Raycast but simpler)
#   - Dunst    — notification daemon
#   - Hyprpaper — wallpaper
#   - Swaylock — screen lock
#   - Nemo     — file manager
#   - Polkit   — privilege escalation dialogs
{ config, pkgs, lib, ... }:

{
  # ── Hyprland compositor ───────────────────────────────────────
  # KDE Plasma 6 fallback (NVIDIA-compatible)
  services.xserver.enable = true;
  services.xserver.windowManager.openbox.enable = true;
  services.displayManager.sddm.enable = true;


  # ── NVIDIA + Hyprland workaround ──────────────────────────────
  # Hardware cursor rendering flickers/stutters on NVIDIA.
  # https://wiki.hyprland.org/Configuring/Environment-variables/
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
  };


  # ── Desktop packages ──────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    firefox
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    neovim
    nerd-fonts.jetbrains-mono
    neovim
    # Bar & launcher
    waybar
    wofi

    # Notifications
    dunst
    libnotify

    # Wallpaper & lockscreen
    hyprpaper
    swaylock
    swayidle

    # Utilities
    nemo                   # File manager
    nemo-fileroller        # Archive integration
    polkit_gnome           # Auth dialogs for GUI apps
    brightnessctl          # Screen brightness (if needed)
    pavucontrol            # Audio mixer
    networkmanagerapplet   # Network tray icon

    # Fonts for waybar/icons
  # Fonts
    noto-fonts
    noto-fonts-color-emoji

    # Screenshot
    grim                   # Wayland screenshot
    slurp                  # Region selection for grim
    wl-clipboard           # Clipboard utilities
  ];

  # ── XDG portals (file dialogs, screen sharing) ────────────────
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    configPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # ── Audio (PipeWire) ───────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ── Fonts ──────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    monospace = [ "FiraCode Nerd Font" ];
    sansSerif = [ "Noto Sans" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # ── Bluetooth (if needed) ──────────────────────────────────────
  hardware.bluetooth.enable = lib.mkDefault false;

  # ── Printing (if needed) ───────────────────────────────────────
  services.printing.enable = lib.mkDefault false;

  # ── Automatic login (optional — uncomment for convenience) ────
  # services.displayManager.autoLogin = {
  #   enable = true;
  #   user = "lucas";
  # };
}
