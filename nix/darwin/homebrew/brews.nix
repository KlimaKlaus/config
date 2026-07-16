{ config, pkgs, lib, ... }:

{
  homebrew.brews = [
    "aoe"
    "apache-spark"
    "bun"
    "container"
    "firebase-cli"
    "gradle@7"
    "mas"                  # Mac App Store CLI
    "minio-warp"
    "mole"
    "multica"
    "nightlight"
    "opencode"
    "openvino"
    "parquet-cli"
    "python@3.12"
    "postgresql@14"
    "redis"

    "remindctl"
    "sdkman-cli"
    "tmux"                 # dep of aoe
    "apfel"
  ];
}
