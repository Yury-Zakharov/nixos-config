{ config, pkgs, lib, ... }:

{
  services.llama-cpp = {
    enable = true;

    # Vulkan for 780M (ROCm is flaky on Phoenix1)
    package = pkgs.llama-cpp.override {
      vulkanSupport = true;
      rocmSupport = false;
      blasSupport = true;          # CPU fallback + faster RAM layers
    };

    # Your model (single source of truth) — Gemma-4 QAT UD-Q4_K_XL
    model = "/var/lib/llama-cpp/gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf";

    # OpenAI-compatible + built-in web UI
    port = 8080;
    host = "127.0.0.1";
    openFirewall = false;

    # Fine config for Gemma-4 MoE (converted from your old extraFlags)
    settings = {
      # GPU / MoE / performance
      ngl = 99;
      ctx-size = 262144;           # 256k — reduce to 131072 if you hit VRAM pressure
      batch-size = 512;
      ubatch-size = 512;
      no-mmap = true;
      cpu-moe = true;              # MoE experts on CPU/RAM (recommended for your 780M)

      # Chat template (important for Gemma-4-IT)
      jinja = true;
      chat-template-kwargs = ''{"enable_thinking": false}'';

      # Idle unload
      sleep-idle-seconds = 600;

      # Sampling (tuned for code + general use)
      temp = 0.7;
      top-p = 0.95;
      min-p = 0.05;
      top-k = 40;
      repeat-penalty = 1.08;
      presence-penalty = 0.6;
      frequency-penalty = 0.0;

      # KV cache (good quality/speed trade-off on 16 GiB iGPU)
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
    };
  };

  # Required for Vulkan on AMD iGPU
  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;

  # Optional: ensure it starts on boot (upstream already does this, but harmless)
  systemd.services.llama-cpp.wantedBy = lib.mkForce [ "multi-user.target" ];
}
