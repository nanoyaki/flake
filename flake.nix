{
  description = "Hana's NixOS System flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    prismlauncher.url = "github:PrismLauncher/PrismLauncher";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      catppuccin,
      prismlauncher,
      home-manager,
      nur,
      ...
    }:

    let
      defaults = [
        nur.nixosModules.nur
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
