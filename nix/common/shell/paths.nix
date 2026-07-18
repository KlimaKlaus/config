{ config, pkgs, lib }:

{
  content = ''

    # ── PATH additions ───────────────────────────────────────
    # Homebrew paths (macOS only)
    if [ -d "/opt/homebrew/bin" ]; then
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    fi
    # Bun
    if [ -d "$HOME/.bun/bin" ]; then
      export PATH="$HOME/.bun/bin:$PATH"
    fi
    export PATH="$HOME/.cargo/bin:$PATH"
    export PATH="$HOME/.dotnet/tools:$PATH"
    export PATH="$HOME/.local/bin:$PATH"


  '';
}
