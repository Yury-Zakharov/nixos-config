{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs:
  let
    mkNixosSystem = hostname: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs hostname; };
      modules = [
        ./configuration.nix
        ./hosts/${hostname}/hardware-configuration.nix
        home-manager.nixosModules.home-manager
      ];
    };
  in
  {
    nixosConfigurations.nixos = mkNixosSystem "nixos";
    # Add future hosts here with one line each:
    # nixosConfigurations.newhost = mkNixosSystem "newhost";
  };
}
