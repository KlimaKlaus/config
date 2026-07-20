{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    docker
  ] ++ lib.optionals stdenv.isDarwin [
    aerospace
    slack
    zed-editor
    sioyek
    jankyborders
    lmstudio
  ] ++ lib.optionals stdenv.isLinux [
    # LLM/dev tools for the NixOS desktop
    # CUDA packages are in environment.systemPackages (nixos/default.nix) —
    # only add user-level tools here to avoid duplication.
    nvidia-docker
    ollama
  ];
}
