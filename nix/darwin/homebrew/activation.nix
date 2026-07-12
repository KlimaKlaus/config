{ config, pkgs, lib, ... }:

{
  # Trust third-party taps so Homebrew doesn't refuse on rebuild.
  system.activationScripts.brewTrust.text =
    let
      user = config.system.primaryUser;
      taps = config.homebrew.taps;
    in
    lib.concatStringsSep "\n" (map (tap: ''
      /opt/homebrew/bin/brew tap "${tap}" 2>/dev/null || true
      sudo -u ${user} -H /opt/homebrew/bin/brew trust "${tap}" 2>/dev/null || true
    '') taps);

  # Brew 5.x: cleanup runs manually after activation
  system.activationScripts.brewCleanup.text = ''
    BREWFILE=$(find /nix/store -maxdepth 1 -name "*-Brewfile" -newer /run/current-system -print -quit 2>/dev/null)
    if [ -n "$BREWFILE" ] && [ -f "$BREWFILE" ]; then
      HOMEBREW_BUNDLE_FORCE_CLEANUP=1 /opt/homebrew/bin/brew bundle cleanup --force --file "$BREWFILE" || true
    fi
  '';
}
