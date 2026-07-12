{ config, pkgs, lib }:

{
  content = ''

    # ── Time format ─────────────────────────────────────────
    TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

    # ── Multica env ─────────────────────────────────────────
    export MULTICA_AGENT_RUNTIME_PROVIDER="docker"
    export MULTICA_AGENT_DEFAULT_IMAGE="ghcr.io/multica-ai/multica-agent-env:latest"
  '';
}
