{
  description = "Nik's NixOS System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = {
    nixpkgs,
    nixpkgs-xr,
    catppuccin,
    home-manager,
    ...
  } @ inputs: let
    username = "niklasuwu";
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      inherit username;
    };
  in {
    nixosConfigurations = {
      # Main System
      niklasuwu-nixos = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          nixpkgs-xr.nixosModules.nixpkgs-xr
          ./hosts/niklasuwu-nixos/configuration.nix
          ./common/configuration.nix
          catppuccin.nixosModules.catppuccin
        ];
      };
    };
  };
}
