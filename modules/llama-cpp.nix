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
    model = "/var/lib/llama-models/gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf";

    # OpenAI-compatible + built-in web UI
    port = 8080;
    host = "127.0.0.1";
    openFirewall = false;

    # Fine config (MoE + generous context)
    extraFlags = [
        "-ngl" "99"
        "-c" "262144"          # start here; 131072 (128k) if 256k is too big
        "-b" "512"
        "--ubatch-size" "512"
        "--no-mmap"
        "--cpu-moe"            # or "-ot" ".ffn_.*_exps.=CPU" if --cpu-moe not recognised
        "--host" "127.0.0.1"
        "--jinja"              # proper chat template for IT model
        "--enable-auto-tool-choice"
        "--tool-call-parser" "gemma4"
        "--sleep-idle-seconds" "600"

        # Sampling tuned for code + general (quality first)
        "--temp" "0.7"
        "--top-p" "0.95"
        "--min-p" "0.05"
        "--top-k" "40"
        "--repeat-penalty" "1.08"
        "--presence-penalty" "0.6"   # light; helps long code sessions without killing creativity
        "--frequency-penalty" "0.0"

        # KV cache (saves VRAM, minor quality win)
        "--cache-type-k" "q8_0"
        "--cache-type-v" "q8_0"
    ];
  };

  # Required for Vulkan
  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;  # helps detection

  # Optional: preload on boot
  systemd.services.llama-cpp.wantedBy = lib.mkForce [ "multi-user.target" ];
}
