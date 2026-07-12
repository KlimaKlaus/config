{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg
    imagemagick
    libass
    tesseract
    libwebp
    libjxl
    libaom
    xz
    sfml
    pandoc
    openblas
    cmake
    gcc
    pango
    pcre
    cargo-c
  ];
}
