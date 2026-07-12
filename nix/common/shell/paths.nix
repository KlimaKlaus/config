{ config, pkgs, lib }:

{
  content = ''

    # ── PATH additions ───────────────────────────────────────
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.bun/bin:$PATH"
    export PATH="$HOME/.cargo/bin:$PATH"
    export PATH="$HOME/.dotnet/tools:$PATH"
    export PATH="$HOME/.local/bin:$PATH"

    # ── SDKMAN (needs manual decision) ───────────────────────
    # export SDKMAN_DIR="$HOME/.sdkman"
    # [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

    # ── Anaconda (needs manual decision) ─────────────────────
    # export PATH=/usr/local/anaconda3/bin:$PATH
  '';
}
