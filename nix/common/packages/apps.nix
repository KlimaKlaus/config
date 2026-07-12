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
    (pkgs.callPackage ../../packages/openwhispr.nix { })
  ];
}
