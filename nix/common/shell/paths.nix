{ config, pkgs, lib }:

{
  content = ''

    # ── PATH additions ───────────────────────────────────────
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.bun/bin:$PATH"
    export PATH="$HOME/.cargo/bin:$PATH"
    export PATH="$HOME/.dotnet/tools:$PATH"
    export PATH="$HOME/.local/bin:$PATH"


  '';
}
