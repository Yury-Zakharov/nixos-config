{ config, pkgs, lib, ... }:

let
  cfg = config.services.llama-cpp;
in
{
  options.services.llama-cpp = {
    cacheDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/cache/llama-cpp";
      example = "/var/cache/llama-cpp";
      description = ''
        Directory used for Vulkan shader cache and other llama.cpp caches.
        Will be created automatically with correct permissions.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.llama-cpp = {
      enable = true;

      package = pkgs.llama-cpp.override {
        vulkanSupport = true;
        rocmSupport = false;
        blasSupport = true;
      };

      settings = {
        model = "/var/lib/llama-cpp/gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf";

        host = "127.0.0.1";
        port = 8080;

        n-gpu-layers = 99;
        ctx-size = 262144;  # 131072;
        batch-size = 512;
        ubatch-size = 512;
        no-mmap = true;
        cpu-moe = true;

        jinja = true;

        sleep-idle-seconds = 600;

        temp = 0.7;
        top-p = 0.95;
        min-p = 0.05;
        top-k = 40;
        repeat-penalty = 1.08;
        presence-penalty = 0.6;
        frequency-penalty = 0.0;

        cache-type-k = "q8_0";
        cache-type-v = "q8_0";
      };
    };

    # Declarative cache handling (XDG + LLAMA_CACHE + systemd CacheDirectory)
    systemd.services.llama-cpp.serviceConfig = {
      CacheDirectory = [ (baseNameOf cfg.cacheDirectory) ];
      Environment = [
        "XDG_CACHE_HOME=${cfg.cacheDirectory}"
        "LLAMA_CACHE=${cfg.cacheDirectory}"
      ];
    };

    hardware.graphics.enable = true;
    hardware.amdgpu.opencl.enable = true;

    systemd.services.llama-cpp.wantedBy = lib.mkForce [ "multi-user.target" ];
  };
}
