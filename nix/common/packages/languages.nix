{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (python312.withPackages (ps: with ps; [
      pip
      virtualenv
      jupyterlab
      numpy
    ]))
    nodejs
    go
    rustc
    cargo
    ruby
    zig
    jdk21
    gradle
    mono
    dotnet-sdk
    yarn
    bazel
    scala-cli
    typst
    uv
  ];
}
