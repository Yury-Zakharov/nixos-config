# NixOS Configuration

Declarative, reproducible NixOS + home-manager setup.  
Single owner (you), single declaration site for every module, zero implicit behaviour.  
Hardware configuration is per-host; everything else is shared.

## Repository structure
```text
nixos-config/
├── flake.nix                 # single place that wires everything
├── configuration.nix         # all system modules (GNOME, podman, llama-cpp, etc.)
├── hosts/
│   └── nixos/
│       └── hardware-configuration.nix   # never shared
├── home/                     # home-manager config + modules
├── modules/                  # reusable system modules
└── flake.lock
```


## Day-to-day usage (current machine)
```bash
# Rebuild and switch
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# After editing anything (configuration.nix, home modules, etc.)
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```
## Deploy on a new machine
```bash
# 1. Clone the repo
git clone https://github.com/YOURUSERNAME/nixos-config.git ~/nixos-config
cd ~/nixos-config

# 2. Create host directory and hardware config
NEWHOSTNAME=your-new-hostname   # change this
mkdir -p hosts/$NEWHOSTNAME
nixos-generate-config --show-hardware-config > hosts/$NEWHOSTNAME/hardware-configuration.nix

# 3. Add the new host to flake.nix (one line)
#    nixosConfigurations.$NEWHOSTNAME = mkNixosSystem "$NEWHOSTNAME";

# 4. Rebuild
sudo nixos-rebuild switch --flake ~/nixos-config#$NEWHOSTNAME
```
### One-time steps on a brand-new machine (only once, after first rebuild) to reuse the Yubikey dongle

After `sudo nixos-rebuild switch --flake ~/nixos-config#<hostname>` and logging in:

```bash
# 1. Insert YubiKey
gpg --card-status          # fetches public key from card (required first time)

# 2. Set trust level for your signing key (one time only)
gpg --edit-key 8DB60D8EF257AF10
trust
4                          # or 5 for ultimate trust
quit
```
That’s it. No other commands, no key copying, no manual `ssh-add`.

## Switching between machines (same environment)
All common modules live in `configuration.nix` and `home/` — they are reused automatically.
Only hardware differs.

### On any machine, just use its hostname:
```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
sudo nixos-rebuild switch --flake ~/nixos-config#framework-laptop   # example

# The exact same user environment (packages, shell, direnv, ssh, etc.) appears everywhere.
```

## Experiment safely
```bash
git checkout -b experiment-foo
# edit files
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# Roll back instantly
git switch main
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

**No `/etc/nixos` is used. The repo at `~/nixos-config` is the only source of truth.**
