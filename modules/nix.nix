{
  inputs,
  self,
  lib,
  config,
  moduleLocation,
  ...
}:

let
  inherit (lib) mkOption types mapAttrs;
in

{
  options.configurations.nixos = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    default = { };
  };

  options.modules.nixos = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    apply = mapAttrs (
      name: module: {
        _class = "nixos";
        _file = "${toString moduleLocation}#modules.nixos.${name}";
        imports = [ module ];
      }
    );
    default = { };
  };

  config = {
    flake-file.inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    flake-file.inputs.nix-index-database.url = "github:nix-community/nix-index-database";

    flake.nixosConfigurations = lib.mapAttrs (
      hostName: module:

      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          module
          { networking = { inherit hostName; }; }
        ];
      }
    ) config.configurations.nixos;

    configurations.nixos.himawari = {
      imports = [ config.modules.nixos.nix ];
    };

    configurations.nixos.kanokoyuri = {
      imports = [ config.modules.nixos.nix ];
    };

    modules.nixos.nix =
      {
        lib,
        pkgs,
        config,
        ...
      }:

      let
        inherit (lib) mkOption types;
      in

      {
        imports = [ inputs.nix-index-database.nixosModules.default ];

        options.nixpkgs.allowUnfreePkgNames = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            Unfree packages allow the installation of
          '';
        };

        config = {
          nixpkgs.config.allowUnfreePredicate =
            pkg: builtins.elem (lib.getName pkg) config.nixpkgs.allowUnfreePkgNames;

          nix.package = pkgs.nixVersions.latest;
          nix.settings = {
            extra-substituters = [ "https://nix-community.cachix.org" ];
            extra-trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];

            auto-optimise-store = true;
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users = [
              "root"
              "@wheel"
            ];
          };

          nix.registry = lib.mapAttrs (_: input: { flake = input; }) inputs;
          nix.nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

          nix.optimise = {
            automatic = true;
            dates = "daily";
            randomizedDelaySec = "15min";
            persistent = true;
          };

          programs.nix-index = {
            enable = true;
            enableZshIntegration = true;
          };

          programs.nix-index-database = {
            enable = true;
            comma.enable = true;
          };

          programs.nh.enable = true;
          programs.nh.clean = {
            enable = true;
            dates = "weekly";
            extraArgs = "--keep 7 --keep-since 14d";
          };

          programs.git.enable = true;
        };
      };

    perSystem =
      { system, ... }:

      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays;
        };
      };
  };
}
