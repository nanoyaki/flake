{
  description = "Hana's NixOS System flake";

  inputs = {
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    catppuccin.url = "github:catppuccin/nix/main";
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
    nixpkgs-xr,
    envision,
    aagl,
    catppuccin,
    home-manager,
    ...
  } @ inputs: let
    username = "hana";
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
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
                  catppuccin.homeManagerModules.catppuccin
                  ./common/home.nix
                  ./hosts/hana-nixos/home.nix
                ];
              };
            };
            imports = [aagl.nixosModules.default];
            nix.settings = aagl.nixConfig; # Set up Cachix
            programs = {
              anime-game-launcher.enable = true; # Adds launcher and /etc/hosts rules
              anime-games-launcher.enable = true;
              anime-borb-launcher.enable = true;
              honkers-railway-launcher.enable = true;
              honkers-launcher.enable = true;
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
                  catppuccin.homeManagerModules.catppuccin
                  ./common/home.nix
                  ./hosts/hana-nixos-laptop/home.nix
                ];
              };
            };
          }
        ];
      };
    };
  };
}
