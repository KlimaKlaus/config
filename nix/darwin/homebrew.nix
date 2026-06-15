{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────────────────────
  # Managed Homebrew — declarative brew alongside Nix
  # ──────────────────────────────────────────────────────────────
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      "anomalyco/tap"       # opencode
      "homebrew/services"   # brew services (postgres, redis)
      "nikitabobko/tap"     # aerospace
      "manaflow-ai/cmux"    # cmux (cask)
      "minio/stable"        # minio-warp
      "multica-ai/tap"      # multica
      "sdkman/tap"          # sdkman-cli
      "smudge/smudge"       # nightlight
      "steipete/tap"        # remindctl
      "typewhisper/tap"     # typewhisper (cask)
    ];

    brews = [
      "aoe"
      "apache-spark"
      "bun"
      "container"
      "firebase-cli"
      "gradle@7"
      "minio-warp"
      "mole"
      "multica"
      "nightlight"
      "opencode"
      "openvino"
      "parquet-cli"
      "postgresql@14"
      "python@3.12"
      "redis"
      "remindctl"
      "sdkman-cli"
      "tmux"                 # dep of aoe
      "apfel"
    ];

    casks = [
      "adoptopenjdk"
      "aerospace"
      "android-platform-tools"
      "betterdisplay"
      "claude-code@latest"
      "cmux"
      "copilot-cli"
      "dotnet-sdk"
      "ghostty"
      "gyroflow"
      "handbrake-app"
      "prince"
      "sioyek"
      "visual-studio-code"
      "slack"
      "syntax-highlight"
      "typewhisper"
      "wave"
      "wkhtmltopdf"
      "yaak"
      "zed"
      "zen"
    ];
  };

  # Trust third-party taps so Homebrew doesn't refuse on rebuild.
  # Must run as the real user — darwin-rebuild runs activation as root.
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
