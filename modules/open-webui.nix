{ config, pkgs, lib, ... }:

{
  services.open-webui = {
    enable = true;

    # Connect to your llama.cpp router (router mode with modelsDir)
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:8080/v1";   # note the /v1
      OPENAI_API_BASE_URL = "http://127.0.0.1:8080/v1";  # also works as OpenAI
      OPENAI_API_KEY = "dummy";                           # not used but required by UI

      # Privacy & minimalism
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";

      # Optional: nicer defaults
      DEFAULT_MODELS = "qwen3-30b-a3b-q5_k_m";  # change to your preferred filename (without .gguf)
    };

    port = 8081;          # different from llama-cpp (8080)
    host = "127.0.0.1";

    # Single owner + state
    stateDir = "/var/lib/open-webui";
  };

  # Dedicated user + directory (single owner)
  systemd.services.open-webui.serviceConfig = {
    StateDirectory = "open-webui";
    StateDirectoryMode = "0700";
  };

  # Make sure llama-cpp starts first
  systemd.services.open-webui.after = [ "llama-cpp.service" ];
  systemd.services.open-webui.wants = [ "llama-cpp.service" ];

  # Start at boot
  systemd.services.open-webui.wantedBy = lib.mkForce [ "multi-user.target" ];
}
