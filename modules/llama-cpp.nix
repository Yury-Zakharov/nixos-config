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

    # Your model (single source of truth)
    model = "/var/lib/llama-models/qwen3-30b-a3b-q5_k_m.gguf";

    # OpenAI-compatible + built-in web UI
    port = 8080;
    host = "127.0.0.1";
    openFirewall = false;

    # Fine config (MoE + generous context)
    extraFlags = [
      "-ngl" "99"          # full GPU offload (16 GiB VRAM)
      "-c" "131072"        # 128k context
      "-b" "512"           # batch size (tune if OOM)
      "--no-mmap"          # safer on iGPU
      # "--flash-attn"
      "--cpu-moe"                    # New simple flag: puts all expert weights on CPU
      # "--n-cpu-moe" "8"         # Alternative: move experts from first N layers to CPU
      "--host" "127.0.0.1"
      "--sleep-idle-seconds" "600" # unload after 10 minutes of idle time
      "--temp" "0.7"          # balanced for your use cases
      "--min-p" "0.05"        # modern default
      "--top-k" "0"           # off
      "--top-p" "1.0"         # off
      "--repeat-last-n" "-1"          # full context (best for long tasks)
      "--repeat-penalty" "1.08"       # mild
      "--presence-penalty" "0.8"      # good balance for Qwen3
      "--frequency-penalty" "0.0"     # usually off unless very long outputs
    ];
  };

  # Required for Vulkan
  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;  # helps detection

  # Optional: preload on boot
  systemd.services.llama-cpp.wantedBy = lib.mkForce [ "multi-user.target" ];
}
