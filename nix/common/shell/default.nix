{ config, pkgs, lib, ... }:

let
  initContent = (import ./init.nix { inherit config pkgs lib; }).content;
  aliasesContent = (import ./aliases.nix { inherit config pkgs lib; }).content;
  pathsContent = (import ./paths.nix { inherit config pkgs lib; }).content;
  completionsContent = (import ./completions.nix { inherit config pkgs lib; }).content;
  envContent = (import ./env.nix { inherit config pkgs lib; }).content;
in
{
  imports = [ ./starship.nix ];

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    initContent = lib.concatStrings [
      initContent
      pathsContent
      aliasesContent
      completionsContent
      envContent
    ];
  };
}
