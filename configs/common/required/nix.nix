{
  self,
  lib,
  inputs,
  pkgs,
  config,
  username,
  ...
}:

let
  inherit (lib) mkOption types;
  inherit (inputs)
    nur
    lazy-apps
    nixpkgs-stable
    nanopkgs
    ;

  cfg = config.nanoflake.nix;
in

{
  options.nanoflake.nix = {
    flakeDir = mkOption {
      type = types.str;
      default = "/home/${username}/flake";
      example = "/etc/nixos/configuration";
      description = "The location of this flake";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.flakeDir != "";
        message = "Flake path must not be empty";
      }
    ];

    nixpkgs.overlays = [
      (final: prev: {
        stable = import nixpkgs-stable {
          inherit (final.stdenv.hostPlatform) system;
          inherit (config.nixpkgs) config;
        };
        # https://github.com/NixOS/nixpkgs/issues/425323
        jdk8 = if (lib.version == "25.11.20250714.62e0f05") then final.openjdk8-bootstrap else prev.jdk8;
        jdk8_headless = final.jdk8;
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
          "https://cache.theless.one/"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
          "cache.theless.one-1:qv138q648suu8rK+bPkGxkz+ZNrCGrwig8Kof/hWVMU="
        ];

        auto-optimise-store = true;
      };

      optimise = {
        automatic = true;
        dates = "daily";
        randomizedDelaySec = "15min";
        persistent = true;
      };

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 14d";
        randomizedDelaySec = "15min";
        persistent = true;
      };

      registry = {
        self.flake = self;
      } // lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    };

    environment.sessionVariables.FLAKE_DIR = cfg.flakeDir;

    environment.systemPackages = with pkgs; [
      nixfmt-rfc-style
      nixd
      nix-fast-build
    ];

    programs.direnv.enable = true;
  };
}
