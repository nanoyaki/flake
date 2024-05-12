{
  description = "Hana's NixOS System flake";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Theme
    catppuccin.url = "github:catppuccin/nix";

    # home-manager, used for managing user configuration
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
    catppuccin,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    # Replace with your hostname
    nixosConfigurations = {
      hana-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./common/configuration.nix
          ./hosts/hana-nixos/configuration.nix
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.hana = {
              imports = [
                ./common/home.nix
                catppuccin.homeManagerModules.catppuccin
              ];
            };
          }
        ];
      };

      hana-nixos-laptop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./common/configuration.nix
          ./hosts/hana-nixos-laptop/configuration.nix
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.hana = {
              imports = [
                ./common/home.nix
                catppuccin.homeManagerModules.catppuccin
              ];
            };
          }
        ];
      };
    };
  };
}
