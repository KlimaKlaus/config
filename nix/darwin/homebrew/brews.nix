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
    "postgresql@14"
    "python@3.12"
    "redis"
    "remindctl"
    "sdkman-cli"
    "tmux"                 # dep of aoe
    "apfel"
  ];
}
