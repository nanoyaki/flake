{
  self,
  lib,
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkOption types;
  inherit (inputs) nur;

  cfg = config.nanoflake.nix;
in

{
  options.nanoflake.nix = {
    flakeDir = mkOption {
      type = types.str;
      default = "$HOME/flake";
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
      self.overlays.default
      nur.overlays.default
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

      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    };

    environment.variables.FLAKE_DIR = cfg.flakeDir;

    environment.systemPackages = with pkgs; [
      nixfmt-rfc-style
      nixd
      nix-fast-build
    ];

    programs.direnv.enable = true;
  };
}
