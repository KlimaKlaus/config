{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    spotify
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
    cudaPackages.cuda_nvcc
    cudaPackages.cudnn
    cudaPackages.cutensor
    nvidia-docker
    ollama
  ];
}
