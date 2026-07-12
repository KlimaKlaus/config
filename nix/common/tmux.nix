{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 5000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-b";
    # Full config is symlinked via dotfiles.nix — this just ensures
    # the binary and basic defaults are in place.
  };

  # TPM plugins managed at runtime by ~/.tmux/plugins/tpm.
}
