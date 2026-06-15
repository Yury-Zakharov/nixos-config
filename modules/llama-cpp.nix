{ config, pkgs, lib, ... }:

{
  services.llama-cpp = {
    enable = true;

    # Vulkan for 780M (ROCm is flaky on Phoenix1)
    package = pkgs.llama-cpp.override {
      vulkanSupport = true;
      rocmSupport = false;
      blasSupport = true;
    };

    # All configuration now lives here (no top-level model/host/port)
    settings = {
      # Model (single source of truth) — moved under /var/lib/llama-cpp/
      model = "/var/lib/llama-cpp/gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf";

      # Server
      host = "127.0.0.1";
      port = 8080;

      # MoE + performance (Gemma-4 26B-A4B)
      ngl = 99;
      ctx-size = 262144;           # start with 256k; drop to 131072 if you OOM
      batch-size = 512;
      ubatch-size = 512;
      no-mmap = true;
      cpu-moe = true;

      # Chat template for Gemma-4-IT (no thinking for coding/agents)
      jinja = true;
      chat-template-kwargs = ''{"enable_thinking": false}'';

      # Idle unload after 10 min
      sleep-idle-seconds = 600;

      # Sampling (code + general, quality first)
      temp = 0.7;
      top-p = 0.95;
      min-p = 0.05;
      top-k = 40;
      repeat-penalty = 1.08;
      presence-penalty = 0.6;
      frequency-penalty = 0.0;

      # KV cache
      cache-type-k = "q8_0";
      cache-type-v = "q8_0";
    };
  };

  # Hardware for Vulkan on 780M
  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;

  # Optional (upstream already does this)
  systemd.services.llama-cpp.wantedBy = lib.mkForce [ "multi-user.target" ];
}
