{ config, pkgs, ... }:

let
  # ── Node packages installed globally ───────────────────────────
  nodePkgs = with pkgs.nodePackages; [
    # firebase-tools — was "firebase-cli" in brew
    # TODO: uncomment if needed; requires node_modules
    # firebase-tools
  ];
in
{
  home.packages = with pkgs; [

    # ── CLI essentials ──────────────────────────────────────────
    git          # brew "git"
    gh           # brew "gh"
    curl         # brew "curl"
    fzf          # brew "fzf"
    gnupg        # brew "gnupg"
    ripgrep      # brew dep — explicit
    starship     # brew "starship"
    lazygit      # brew "lazygit"
    tmux         # brew dep — explicit
    tree         # diagnostic
    figlet       # brew "figlet"

    # ── Languages & runtimes ────────────────────────────────────
    python312              # brew "python@3.12"
    python312Packages.pip  # always handy
    python312Packages.virtualenv
    nodejs                 # brew "node"
    go                     # brew "go"
    rustc                  # brew "rust"
    cargo
    ruby                   # brew "ruby"
    zig                    # brew "zig"
    jdk21                  # brew "openjdk@21"
    gradle                 # brew "gradle@7" — using latest; pin if needed
    mono                   # brew "mono"
    dotnet-sdk             # brew "dotnet-sdk" (cask)
    yarn                   # brew "yarn"
    bazel                  # brew "bazel"
    scala-cli              # brew "scala-cli" — confirmed in nixpkgs
    typst                  # brew dep — explicit

    # ── Data & databases ────────────────────────────────────────
    duckdb       # brew "duckdb"
    mosquitto    # brew "mosquitto"

    # ── Cloud & infra ───────────────────────────────────────────
    azure-cli              # brew "azure-cli"
    yubikey-manager        # brew "ykman"
    tailscale              # brew "tailscale"

    # ── Media & graphics ────────────────────────────────────────
    ffmpeg                 # brew "ffmpeg"
    imagemagick            # brew "imagemagick"
    libass                 # brew "libass"
    tesseract              # brew "tesseract"
    libwebp                # brew "webp" → libwebp
    libjxl                 # brew "jpeg-xl" → libjxl
    libaom                  # brew "aom" → libaom
    xz                     # brew "xz"
    sfml                   # brew "sfml"
    pandoc                 # brew "pandoc"
    openblas               # brew "openblas"
    cmake                  # brew "cmake"
    gcc                    # brew "gcc"
    pango                  # brew "pango"
    pcre                   # brew "pcre"
    cargo-c                # brew "cargo-c"
    # handbrake — marked broken in nixpkgs; kept via homebrew

    # ── Data science & Python ───────────────────────────────────
    python312Packages.jupyterlab  # brew "jupyterlab"
    python312Packages.numpy  # brew "numpy"
    # openvino — marked broken in nixpkgs on darwin; kept via homebrew

    # ── macOS applications ──────────────────────────────────────
    # ghostty — Linux-only in nixpkgs; kept via homebrew cask
    aerospace              # brew "aerospace" (cask)
    slack                  # brew "slack" (cask)
    zed-editor             # brew "zed" (cask)
    # zen-browser — not in nixpkgs; kept via homebrew
    sioyek                 # brew "sioyek" (cask)

    # ── System tools ────────────────────────────────────────────
    android-tools          # brew "android-platform-tools" (cask)
    # wkhtmltopdf — x86_64-darwin only in nixpkgs; kept via homebrew
    cacert                 # brew "ca-certificates"

    # ── CLI extras from your brew list ──────────────────────────
    bitwarden-cli          # brew "bitwarden-cli"
    himalaya               # brew "himalaya"
  ];

  # ────────────────────────────────────────────────────────────
  # Packages NOT in nixpkgs — keep via Homebrew (see darwin/homebrew.nix)
  # ────────────────────────────────────────────────────────────
  # opencode, multica, claude-code, cmux, copilot-cli,
  # gyroflow, prince, slimhud, syntax-highlight, typewhisper,
  # wave, yaak, betterdisplay, nightlight, minio-warp, mole,
  # firebase-cli, parquet-cli, apache-spark
}
