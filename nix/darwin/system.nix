{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────────────────────
  # macOS System Defaults
  # ──────────────────────────────────────────────────────────────
  system.defaults = {
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      AppleShowAllExtensions = true;
      NSWindowResizeTime = 0.001;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
      NSDocumentSaveNewDocumentsToCloud = false;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.3;
      orientation = "bottom";
      show-recents = false;
      minimize-to-application = true;
      magnification = true;
      persistent-apps = [
        # TODO: add pinned apps, e.g.
        # "/System/Applications/System Settings.app"
        # "/Applications/Ghostty.app"
      ];
      persistent-others = [
        # TODO: e.g. { path = "~/Downloads"; }
      ];
    };

    finder = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv";
      FXDefaultSearchScope = "SCcf";
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
    };

    trackpad = {
      Clicking = true;
    };

    screencapture = {
      disable-shadow = true;
    };

    loginwindow = {
      SHOWFULLNAME = true;
    };
  };

  # ── Apply extra macOS defaults not covered by nix-darwin ──────
  system.activationScripts.extra.text = ''
    # Three-finger drag
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

    # Hot corners:
    #  0 = nothing, 2 = Mission Control, 3 = App Windows,
    #  4 = Desktop, 5 = Screensaver, 6 = Sleep, 7 = Notifications
    # defaults write com.apple.dock wvous-tl-corner -int 2   # Top-left → Mission Control
    # defaults write com.apple.dock wvous-tl-modifier -int 0
    # defaults write com.apple.dock wvous-br-corner -int 4   # Bottom-right → Desktop
    # defaults write com.apple.dock wvous-br-modifier -int 0
  '';
}
