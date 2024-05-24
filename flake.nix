{
  description = "Hana's NixOS System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    catppuccin.url = "github:catppuccin/nix";
    envision.url = "gitlab:Scrumplex/envision/nix";
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
    nixpkgs-xr,
    envision,
    catppuccin,
    home-manager,
    ...
  } @ inputs: let
    username = "hana";
    system = "x86_64-linux";
    pkgs-stable = import nixpkgs-unstable {
      inherit system;
      config = {allowUnfree = true;};
    };
    specialArgs = {
      inherit inputs;
      inherit pkgs-stable;
      inherit username;
    };
  in {
    nixosConfigurations = {
      # Main System
      hana-nixos = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          nixpkgs-xr.nixosModules.nixpkgs-xr
          ./hosts/hana-nixos/configuration.nix
          ./common/configuration.nix
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = {
                imports = [
                  ./common/home.nix
                  ./hosts/hana-nixos/home.nix
                  inputs.catppuccin.homeManagerModules.catppuccin
                ];
              };
            };
          }
        ];
      };

      # TODO: MAKE THIS GOOD FOR THE LOVE OF GOD

      # Laptop
      hana-nixos-laptop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./hosts/hana-nixos-laptop/configuration.nix
          ./common/configuration.nix
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = {
                imports = [
                  ./common/home.nix
                  ./hosts/hana-nixos-laptop/home.nix
                  inputs.catppuccin.homeManagerModules.catppuccin
                ];
              };
            };
          }
        ];
      };
    };
  };
}
