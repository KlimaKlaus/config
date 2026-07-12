{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────────────────────
  # Git
  # ──────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    signing = {
      key = "E8DE72E441853146";
      signByDefault = true;
    };
    settings = {
      user = {
        name = lib.mkForce "lucasfth";
        email = lib.mkForce "online@lucashanson.dk";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      core.pager = "${pkgs.delta}/bin/delta";
      diff.colorMoved = "default";
      interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
      delta.navigate = true;
      merge.conflictstyle = "zdiff3";
    };
  };

  # ──────────────────────────────────────────────────────────────
  # GitHub CLI
  # ──────────────────────────────────────────────────────────────
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      user = "lucasfth";
    };
  };

  # ──────────────────────────────────────────────────────────────
  # GPG (for commit signing)
  # ──────────────────────────────────────────────────────────────
  programs.gpg = {
    enable = true;
    # Your secret key is already in the keyring (~/.gnupg/).
    # Home Manager can also manage public keys and config, but
    # for now we just ensure GPG is available.
    settings = {
      # Use a modern key format
      keyid-format = "long";
      with-keygrip = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    # Let GPG agent serve as SSH agent too (useful for git+ssh)
    enableSshSupport = true;
    # Cache PIN for 8 hours
    defaultCacheTtl = 28800;
    maxCacheTtl = 28800;
  };
}
