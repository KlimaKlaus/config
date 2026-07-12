{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    duckdb
    mosquitto
    juicefs
  ];
}
