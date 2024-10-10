{
  description = "Hana's NixOS System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    prismlauncher.url = "github:PrismLauncher/PrismLauncher";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      catppuccin,
      prismlauncher,
      home-manager,
      plasma-manager,
      ...
    }:

    let
      defaults = [
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        ./common/configuration.nix
      ];

      # I think this is good :)
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            username = "hana";
          };

          modules = defaults ++ [
            (./. + "/hosts/${hostname}/configuration.nix")
          ];
        };
    in

    {
      nixosConfigurations = {
        hana-nixos = mkSystem "hana-nixos";
        hana-nixos-laptop = mkSystem "hana-nixos-laptop";
      };
    };
}
