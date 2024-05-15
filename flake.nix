{
  description = "Niklas' NixOS System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-23.11";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    catppuccin,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs-stable = import nixpkgs-unstable {
      inherit system;
      config = {allowUnfree = true;};
    };
    specialArgs = {
      inherit inputs;
      inherit pkgs-stable;
    };
    defaultModules = [
      ./common/configuration.nix
      catppuccin.nixosModules.catppuccin
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          backupFileExtension = "backup";
          useGlobalPkgs = true;
          useUserPackages = true;
          users.niklas-uwu = {
            imports = [
              ./common/home.nix
              inputs.catppuccin.homeManagerModules.catppuccin
            ];
          };
        };
      }
    ];
  in {
    nixosConfigurations = {
      # Main System
      niklas-uwu-nixos = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules =
          defaultModules
          ++ [
            ./hosts/niklas-uwu-nixos/configuration.nix
          ];
      };
    };
  };
}
