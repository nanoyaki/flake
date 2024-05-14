{
  description = "Hana's NixOS System flake";

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
    pkgs-stable = nixpkgs-unstable.legacyPackages.${system};
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
          users.hana = {
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
      hana-nixos = nixpkgs.lib.nixosSystem {
        modules =
          defaultModules
          ++ [
            ./hosts/hana-nixos/configuration.nix
          ];
      };

      # Laptop
      hana-nixos-laptop = nixpkgs.lib.nixosSystem {
        modules =
          defaultModules
          ++ [
            ./hosts/hana-nixos-laptop/configuration.nix
          ];
      };
    };
  };
}
