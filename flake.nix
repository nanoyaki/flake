{
  description = "Niklas' NixOS System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # lanzaboote = {
    #   url = "github:nix-community/lanzaboote/v0.4.1";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = {
    nixpkgs,
    catppuccin,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
  in {
    nixosConfigurations = {
      # Main System
      niklasuwu-nixos = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./configuration.nix
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.niklasuwu = {
                imports = [
                  ./home.nix
                  inputs.catppuccin.homeManagerModules.catppuccin
                ];
              };
            };
          }
          # lanzaboote.nixosModules.lanzaboote
          # ({ pkgs, lib, ... }: {
          #   environment.systemPackages = [
          #     # For debugging and troubleshooting Secure Boot.
          #     pkgs.sbctl
          #   ];

            # Lanzaboote currently replaces the systemd-boot module.
            # This setting is usually set to true in configuration.nix
            # generated at installation time. So we force it to false
            # for now.
          #   boot.loader.systemd-boot.enable = lib.mkForce false;

          #   boot.lanzaboote = {
          #     enable = true;
          #     pkiBundle = "/etc/secureboot";
          #   };
          # })
        ];
      };
    };
  };
}
