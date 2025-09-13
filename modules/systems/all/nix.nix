{
  self,
  lib,
  lib',
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (inputs)
    nur
    lazy-apps
    nixpkgs-stable
    nanopkgs
    ;
  inherit (lib) mkPackageOption;
  inherit (lib'.options) mkDefault mkPathOption;

  cfg = config.config'.nix;
in

{
  options.config'.nix = {
    flakeDir = mkDefault "${config.hm.home.homeDirectory}/flake" mkPathOption;
    rebuildScript = mkPackageOption pkgs "nh" { };
  };

  config = {
    nixpkgs.overlays = [
      (final: _: {
        stable = import nixpkgs-stable {
          inherit (final.stdenv.hostPlatform) system;
          inherit (config.nixpkgs) config;
        };
      })
      nanopkgs.overlays.default
      nur.overlays.default
      lazy-apps.overlays.default
    ];
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        trusted-users = [
          "root"
          "@wheel"
        ];
        trusted-substituters = [
          "https://cache.nixos.org/"
          "https://hydra.nixos.org/"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        auto-optimise-store = true;
      };

      optimise = {
        automatic = true;
        dates = "daily";
        randomizedDelaySec = "15min";
        persistent = true;
      };

      registry = {
        self.flake = self;
      }
      // lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    };

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "daily";
        extraArgs = "--keep 10 --keep-since 7d";
      };
      flake = cfg.flakeDir;
    };

    # rebuilding purposes
    environment.sessionVariables.FLAKE_DIR = cfg.flakeDir;
    programs.direnv.enable = true;
    environment.systemPackages = [ pkgs.nix-fast-build ];
  };
}
