{ config, pkgs, lib }:

{
  content = ''

    # ── SSH aliases (defined in ~/config/nix_secrets) ────────
    alias ssh-termux='ssh "$TERMUX_USER@$TERMUX_IP" -p "$TERMUX_PORT"'
    alias ssh-windows='ssh "$WINDOWS_USER@$WINDOWS_IP"'
    alias ecoray-mimer='ssh "$ECORAY_MIMER_USER@$ECORAY_MIMER_IP"'
    alias mimer='ecoray-mimer'
    alias ecoray-vps1='ssh "$ECORAY_VPS1_USER@$ECORAY_VPS1_IP"'
    alias se1='ecoray-vps1'
    alias se1lv='ssh -t "$ECORAY_VPS1_USER@$ECORAY_VPS1_IP" "cd .openclaw/workspace-louise && exec \$SHELL --login"'
    alias ecoray-vps2='ssh "$ECORAY_VPS2_USER@$ECORAY_VPS2_IP"'
    alias se2='ecoray-vps2'
    alias ecoray-vps3='ssh "$ECORAY_VPS3_USER@$ECORAY_VPS3_IP"'
    alias se3='ecoray-vps3'
    alias ecoray-mac-mini='ssh "$ECORAY_MAC_MINI_USER@$ECORAY_MAC_MINI_IP"'
    alias sem='ecoray-mac-mini'
    alias semd='ssh -t "$ECORAY_MAC_MINI_USER@$ECORAY_MAC_MINI_IP" "cd lucasfth/ecoray-web && git checkout development && git pull && exec \$SHELL --login"'
    alias ecoray-pi='ssh "$ECORAY_PI_USER@$ECORAY_PI_IP"'
    alias sep='ecoray-pi'
    alias ecoray-freyr='ssh "$ECORAY_FREYR_USER@$ECORAY_FREYR_IP"'
    alias freyr='ecoray-freyr'

    # ── General aliases ──────────────────────────────────────
    alias lg="lazygit"
    alias gup="git pull --rebase"

    # ── Batch HEIC → TIFF conversion (macOS only — uses sips) ──
    if command -v sips >/dev/null 2>&1; then
    heic2tiff() {
      if [ $# -eq 0 ]; then
        echo "Usage: heic2tiff <file.heic> [file2.HEIC ...]"
        return 1
      fi
      local in out
      for in in "$@"; do
        out="''${in%.*}.tiff"
        echo "→ ''${out}"
        sips -s format tiff "$in" --out "$out"
      done
      echo "Done."
    }
    fi

    # ── OMP wrapper (auto-saves session to vault after exit) ──
    omp() {
      command omp "$@"; local rc=$?
      case "$rc:$1" in
        0:|0:--resume|0:--continue) ~/.omp/agent/hooks/post/save-to-vault.sh "$(pwd)" 2>/dev/null ;;
      esac
      return $rc
    }

    # ── Local binary aliases (not Nix-packaged) ──────────────
    if [ -x "$HOME/Desktop/code/yt-dlp/yt-dlp" ]; then
      alias yt-dlp="$HOME/Desktop/code/yt-dlp/yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata --no-abort-on-error -o './playlist/%(playlist_index)s - %(title)s.%(ext)s'"
    fi
    if [ -x "$HOME/Desktop/code/repolicense-cli/zig-out/bin/repolicense" ]; then
      alias repolicense="$HOME/Desktop/code/repolicense-cli/zig-out/bin/repolicense"
    fi
    alias gtop="~/klaus-services/gtop"
  '';
}
