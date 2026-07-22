{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    docker
  ] ++ lib.optionals stdenv.isDarwin [
    zed-editor
    sioyek
    jankyborders
    lmstudio
  ] ++ lib.optionals stdenv.isLinux [
    nvidia-docker
    ollama
  ];
}
