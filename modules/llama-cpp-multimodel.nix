{ config, pkgs, lib, ... }:

{
  services.llama-cpp = {
    enable = true;

    package = pkgs.llama-cpp.override {
      vulkanSupport = true;
      rocmSupport = false;
      blasSupport = true;
    };

    # Router mode: no single model → multi-model
    model = null;                     # important

    modelsDir = "/var/lib/llama-cpp/models";  # put all your GGUF files here

    port = 8080;
    host = "127.0.0.1";
    openFirewall = false;

    extraFlags = [
      "-c" "131072"
      "-b" "512"
      "--no-mmap"
      "--host" "127.0.0.1"
      "--sleep-idle-seconds" "600"   # per-model idle unload
      "--models-max" "2"             # max models loaded in VRAM at once (tune for 16 GiB)
    ];
  };

  hardware.graphics.enable = true;
  hardware.amdgpu.opencl.enable = true;

  systemd.services.llama-cpp.wantedBy = lib.mkForce [ "multi-user.target" ];

  # Single owner for models directory
  systemd.tmpfiles.rules = [
    "d /var/lib/llama-cpp/models 0750 llama-cpp llama-cpp -"
  ];
}
