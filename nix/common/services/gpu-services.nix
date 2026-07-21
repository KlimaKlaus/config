# GPU Inference Services — Home-Manager User Services
# Replaces tmux-based startup with proper systemd user services.
# Applies to: NixOS host freyr (dual NVIDIA GPU)
#
# GPU layout:
#   GPU 0 (bus 23:00.0) = RTX 3070 (8GB)    — monitor on DP-1
#   GPU 1 (bus 2D:00.0) = RTX 5070 Ti (16GB) — headless compute
#
# Service→GPU mapping:
#   CUDA_VISIBLE_DEVICES=1 (= 5070 Ti): WhisperX :9090, Embedding :8081
#   CUDA_VISIBLE_DEVICES=0 (= 3070):    Vision Qwen :8083 (llama-server)
#   CPU:                                Reranker :8082

{ config, pkgs, lib, hostname, ... }:

let
  inferEnv = "${config.home.homeDirectory}/inference-env";
  srvDir = "${config.home.homeDirectory}/klaus-services";
  modelsDir = "${srvDir}/models";

  # Library path discovery — critical for CUDA + torch on NixOS
  gccLib = pkgs.gcc.cc.lib;
  zlibLib = pkgs.zlib;
  bzip2Lib = pkgs.bzip2;
  stdenvLib = pkgs.stdenv.cc.cc.lib;

  ldLibraryPath = lib.makeLibraryPath [
    gccLib
    zlibLib
    bzip2Lib
    stdenvLib
    pkgs.cudaPackages.cuda_cudart
    pkgs.cudaPackages.cublas
  ] + ":/run/opengl-driver/lib";

  # CUDA merged store path — provides libcudart.so symlinks needed by whisper-cli
  # Created via systemd tmpfiles.d to ensure availability after GC
  cudaLibDir = "/run/opengl-driver/lib";

in
lib.mkIf (hostname == "freyr") {
  # ── systemd user services ─────────────────────────────────────

  systemd.user.services.whisperx = {
    Unit = {
      Description = "WhisperX transcription + diarization API (:9090)";
      After = [ "network.target" ];
      Requires = [ "cuda-symlinks.service" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${inferEnv}/bin/python3 ${srvDir}/server2.py";
      WorkingDirectory = srvDir;
      Restart = "on-failure";
      RestartSec = 30;
      Environment = [
        "PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True"
        "CUDA_VISIBLE_DEVICES=1"
        "LD_LIBRARY_PATH=${ldLibraryPath}"
        "WHISPER_CLI=${srvDir}/whisper-cli"
      ];
      EnvironmentFile = "${config.home.homeDirectory}/.config/gpu-services/hf_token.env";
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.embedding = {
    Unit = {
      Description = "Embedding API — multilingual-e5-large-instruct (:8081)";
      After = [ "network.target" ];
      Requires = [ "cuda-symlinks.service" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${inferEnv}/bin/python3 ${srvDir}/embedding_server.py";
      WorkingDirectory = srvDir;
      Restart = "on-failure";
      RestartSec = 30;
      Environment = [
        "PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True"
        "CUDA_VISIBLE_DEVICES=1"
        "LD_LIBRARY_PATH=${ldLibraryPath}"
      ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.reranker = {
    Unit = {
      Description = "Reranker API — BAAI/bge-reranker-v2-m3 (:8082, CPU)";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${inferEnv}/bin/python3 ${srvDir}/reranker_server.py";
      WorkingDirectory = srvDir;
      Restart = "on-failure";
      RestartSec = 30;
      Environment = [
        "PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True"
        "LD_LIBRARY_PATH=${ldLibraryPath}"
      ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.vision-qwen = {
    Unit = {
      Description = "Vision LLM — Qwen2.5-VL-7B Q4_K_S (:8083)";
      After = [ "network.target" ];
      Requires = [ "cuda-symlinks.service" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${srvDir}/llama-server \
        -m ${modelsDir}/Qwen_Qwen2.5-VL-7B-Instruct-Q4_K_S.gguf \
        --mmproj ${modelsDir}/mmproj-Qwen_Qwen2.5-VL-7B-Instruct-bf16.gguf \
        --host 0.0.0.0 --port 8083 \
        -ngl 99 -c 32768 --image-min-tokens 512";
      WorkingDirectory = srvDir;
      Restart = "on-failure";
      RestartSec = 30;
      Environment = [
        "CUDA_VISIBLE_DEVICES=0"
        "LD_LIBRARY_PATH=${ldLibraryPath}"
      ];
    };
    Install.WantedBy = [ "default.target" ];
  };

  # CUDA symlink fix — creates symlinks in /run/opengl-driver/lib
  # Needed because whisper-cli and some torch builds look for libcudart.so
  # in the opengl-driver path
  systemd.user.services.cuda-symlinks = {
    Unit = {
      Description = "Create CUDA library symlinks in /run/opengl-driver/lib";
      Before = [ "whisperx.service" "embedding.service" "vision-qwen.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "cuda-symlinks" ''
        set -euo pipefail

        NVIDIA_LIB=/run/opengl-driver/lib
        CUDA_MERGED=/nix/store/z0npj5a5fahsqn6snjav5hq5dy34vcj7-cuda-merged-12.9/lib

        mkdir -p "$NVIDIA_LIB"

        # Symlink libcudart.so → CUDA merged
        if [ ! -f "$NVIDIA_LIB/libcudart.so" ]; then
          ln -sf "$CUDA_MERGED/libcudart.so" "$NVIDIA_LIB/libcudart.so"
        fi
        if [ ! -f "$NVIDIA_LIB/libcudart.so.12" ]; then
          ln -sf "$CUDA_MERGED/libcudart.so.12" "$NVIDIA_LIB/libcudart.so.12"
        fi
        if [ ! -f "$NVIDIA_LIB/libcudart.so.12.9.79" ]; then
          ln -sf "$CUDA_MERGED/libcudart.so.12.9.79" "$NVIDIA_LIB/libcudart.so.12.9.79"
        fi

        echo "CUDA symlinks created in $NVIDIA_LIB"
      '';
    };
    Install.WantedBy = [ "default.target" ];
  };

  # ── Home packages needed by GPU services ─────────────────────
  home.packages = with pkgs; [
    # GPU monitoring
    nvitop
  ];

  # ── Onnxruntime: force CPU-only (onnxruntime-gpu incompatible with NixOS CUDA paths) ──
  # The inference venv uses onnxruntime (CPU) which is what we want —
  # no Nix-level override needed since the venv is manually managed.

  # ── HF token file (populated manually or via secret management) ──
  # Create with: echo "HF_TOKEN=hf_yourtokenhere" > ~/.config/gpu-services/hf_token.env
  # Set permissions: chmod 600 ~/.config/gpu-services/hf_token.env
  home.file.".config/gpu-services/.keep".text = ''
    # GPU services configuration directory
    # Place hf_token.env here with: echo "HF_TOKEN=your_token" > hf_token.env
    # chmod 600 hf_token.env
  '';

  # ── Shell aliases ─────────────────────────────────────────────
  programs.zsh.shellAliases = {
    gpu-status = "systemctl --user status whisperx embedding reranker vision-qwen";
    gpu-restart = "systemctl --user restart whisperx embedding reranker vision-qwen";
    gpu-logs = "journalctl --user -u whisperx -u embedding -u reranker -u vision-qwen -f";
  };
}
