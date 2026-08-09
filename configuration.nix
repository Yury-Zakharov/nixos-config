{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      inputs.nixos-hardware.nixosModules.framework-16-7040-amd
      ./modules/llama-cpp.nix
    ];

  # Firmware update manager
  services.fwupd.enable = true;

  # Fingerprint scanner
  services.fprintd.enable = true;

  # Yubikey related
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  services.udev.extraRules = ''
    # Keep only YubiKey 5C NFC alive (VID:PID 1050:0407) — no autosuspend
    SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{idProduct}=="0407", RUN+="/bin/sh -c 'echo on > /sys/bus/usb/devices/%k/power/control; echo -1 > /sys/bus/usb/devices/%k/power/autosuspend_delay_ms'"
  '';

  services.gnome.gcr-ssh-agent.enable = false;

  # Bootloader — single owner, single declaration site, zero implicit behavior
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 7;  # ONLY this controls how many generations appear in the boot menu
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix core settings — single declaration site
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.channel.enable = false;

  # Automatic cleanup — declarative, weekly, single owner
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;

  # Allow unfree packages — explicit, single site
  nixpkgs.config.allowUnfree = true;

  # Explicitly eliminate all channel state — single declaration site, zero implicit NIX_PATH fallback
  environment.etc."nix/nix.conf".text = lib.mkForce ''
    experimental-features = nix-command flakes
    warn-dirty = false
  '';

  # Remove leftover channel profiles on every activation (idempotent, no implicit state)
  system.activationScripts.removeChannels = {
    text = ''
      rm -rf /root/.nix-defexpr/channels /nix/var/nix/profiles/per-user/root/channels
    '';
    deps = [ "etc" ];
  };

  # networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [
      pkgs.samsung-unified-linux-driver
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ########################################
  # Containers — single declaration site
  ########################################

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.containers.enable = true;

  # Define a user account.
  users.users.yury = {
    isNormalUser = true;
    description = "Yury Zakharov";
    extraGroups = [ "networkmanager" "wheel" "podman" "plugdev" ];
    home = "/home/yury";
  };

  ############################################
  # Home Manager — user mapping only
  # (module itself is declared once in flake.nix)
  ############################################

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.yury = import ./home/yury.nix;
  };

  ##############################################
  # Llama-cpp service
  ##############################################

  services.llama-cpp.enable = true;

  ##############################################
  # Other stuff — explicit only
  ##############################################

  # List packages installed in system profile (keep minimal).
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    tree
    treegen
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken.
  system.stateVersion = "25.11";
}
