{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────────────────────
  # Mac App Store apps — installed via `mas` (declared in brews)
  # ──────────────────────────────────────────────────────────────
  # Find IDs: mas search "App Name"  or  https://apps.apple.com/...
  homebrew.masApps = {
    # Xcode = 497799835;
    # Pages = 409201541;
    # Keynote = 409183694;
    # Numbers = 409203825;
    # TestFlight = 899247664;
  };

  # Activation: ensure mas is signed in before install
  # Run once: mas signin apple@id.com
  system.activationScripts.masCheck.text = ''
    if ! /opt/homebrew/bin/mas account >/dev/null 2>&1; then
      echo "⚠ mas not signed in — App Store apps will be skipped"
      echo "  Run: mas signin your@apple.id"
    fi
  '';
}
