{ config, pkgs, ... }:

{
  # ──────────────────────────────────────────────────────────────
  # Zsh
  # ──────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "z" ];
    };

    initContent = ''
      export ZSH="$HOME/.oh-my-zsh"

      # ── Alias-tips plugin (vendored in ~/.zsh/) ────────────
      if [ -f "''$HOME/.zsh/alias-tips/alias-tips.plugin.zsh" ]; then
        source "''$HOME/.zsh/alias-tips/alias-tips.plugin.zsh"
      fi

      # ── Secrets (gitignored, kept on disk) ───────────────────
      if [ -f "''$HOME/config/nix_secrets" ]; then
        source "''$HOME/config/nix_secrets"
      fi

      # ── Local overrides (for quick experiments, no rebuild needed) ──
      if [ -f "''$HOME/.zshrc_local" ]; then
        source "''$HOME/.zshrc_local"
      fi

      # ── Shortcuts ──────────────────────────────────────────────
      rebuild() { sudo darwin-rebuild switch --flake ~/config && exec zsh; }
      alias nrs="rebuild"
      alias nix-search="nix search nixpkgs"
      nix-which() { local p; p="$(which "$1")"; case "$p" in */nix/store/*|*/.nix-profile/*|*/run/current-system/*) echo "$p  ← Nix" ;; /opt/homebrew/*) echo "$p  ← Brew" ;; *) echo "$p" ;; esac; }
      nix-update() { nix flake update --flake ~/config && sudo darwin-rebuild switch --flake ~/config && exec zsh; }
      nix-rollback() { sudo darwin-rebuild --list-generations --flake ~/config; echo "Pick: sudo darwin-rebuild --switch-generation <N> --flake ~/config"; }

      # ── OMP wrapper (auto-saves session to vault after exit) ──
      omp() {
        command omp "$@"; local rc=$?
        # Only save if omp actually ran (exit 0) and was a session
        case "$rc:$1" in
          0:|0:--resume|0:--continue) ~/.omp/agent/hooks/post/save-to-vault.sh "$(pwd)" 2>/dev/null ;;
        esac
        return $rc
      }

			# Saved within ~/config/nix_secrets
      alias ssh-termux='ssh "''${TERMUX_USER}@''${TERMUX_IP}" -p "''${TERMUX_PORT}"'
      alias ssh-windows='ssh "''${WINDOWS_USER}@''${WINDOWS_IP}"'
      alias ecoray-linux='ssh "''${ECORAY_LINUX_USER}@''${ECORAY_LINUX_IP}"'
      alias ecoray-vps1='ssh "''${ECORAY_VPS1_USER}@''${ECORAY_VPS1_IP}"'
      alias ecoray-vps2='ssh "''${ECORAY_VPS2_USER}@''${ECORAY_VPS2_IP}"'
      alias ecoray-vps3='ssh "''${ECORAY_VPS3_USER}@''${ECORAY_VPS3_IP}"'

      # ── General aliases ──────────────────────────────────────
      alias lg="lazygit"
      alias gup="git pull --rebase"

      # ── Local binary aliases (not Nix-packaged) ──────────────
      # ── Local binary aliases (not Nix-packaged, optional) ─────
      if [ -x "''$HOME/Desktop/code/yt-dlp/yt-dlp" ]; then
        alias yt-dlp="''$HOME/Desktop/code/yt-dlp/yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --no-abort-on-error -o './playlist/%(playlist_index)s - %(title)s.%(ext)s'"
      fi
      if [ -x "''$HOME/Desktop/code/repolicense-cli/zig-out/bin/repolicense" ]; then
        alias repolicense="''$HOME/Desktop/code/repolicense-cli/zig-out/bin/repolicense"
      fi

      # ── PATH additions ───────────────────────────────────────
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:''$HOME/.bun/bin:''$PATH"
      export PATH="''$HOME/.cargo/bin:''$PATH"
      export PATH="''$HOME/.dotnet/tools:''$PATH"
      export PATH="''$HOME/.local/bin:''$PATH"
      # ── SDKMAN (needs manual decision) ───────────────────────
      # export SDKMAN_DIR="''$HOME/.sdkman"
      # [[ -s "''$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "''$HOME/.sdkman/bin/sdkman-init.sh"

      # ── Anaconda (needs manual decision) ─────────────────────
      # export PATH=/usr/local/anaconda3/bin:''$PATH

      # ── Mole shell completion ────────────────────────────────
      if output="''$(mole completion zsh 2>/dev/null)"; then eval "''$output"; fi
      # ── Opencode completions ─────────────────────────────────
      ###-begin-opencode-completions-###
      _opencode_yargs_completions()
      {
        local reply
        local si=''$IFS
        IFS=''$'\n' reply=(''$(COMP_CWORD="''$((CURRENT-1))" COMP_LINE="''$BUFFER" COMP_POINT="''$CURSOR" opencode --get-yargs-completions "''${words[@]}"))
        IFS=''$si
        if [[ ''${#reply} -gt 0 ]]; then
          _describe 'values' reply
        else
          _default
        fi
      }
      if [[ "''${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
        _opencode_yargs_completions "''$@"
      else
        compdef _opencode_yargs_completions opencode
      fi
      ###-end-opencode-completions-###

      # ── Time format ─────────────────────────────────────────
      TIMEFMT=''$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

      # ── Multica env ─────────────────────────────────────────
      export MULTICA_AGENT_RUNTIME_PROVIDER="docker"
      export MULTICA_AGENT_DEFAULT_IMAGE="ghcr.io/multica-ai/multica-agent-env:latest"
    '';
  };

  # ──────────────────────────────────────────────────────────────
  # Starship
  # ──────────────────────────────────────────────────────────────
  programs.starship = {
    enable = true;
    # Config is symlinked via dotfiles.nix
  };
}
