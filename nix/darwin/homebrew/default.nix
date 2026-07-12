{ config, pkgs, lib, ... }:

{
  imports = [
    ./brews.nix
    ./casks.nix
    ./mas.nix
    ./activation.nix
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    taps = [
      "anomalyco/tap"       # opencode
      "homebrew/services"   # brew services (postgres, redis)
      "manaflow-ai/cmux"    # cmux (cask)
      "minio/stable"        # minio-warp
      "multica-ai/tap"      # multica
      "sdkman/tap"          # sdkman-cli
      "smudge/smudge"       # nightlight
      "steipete/tap"        # remindctl
    ];
  };
}
