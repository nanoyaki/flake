{ inputs, ... }:

{
  flake.nixosModules.nix =
    { lib, config, ... }:

    {
      options.nixpkgs.allowUnfreeNames = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };

      config = {
        # Use stricter *explicit* policy
        # but don't check meta due to
        # firefox addons with custom
        # meta
        nixpkgs.config.allowUnfreePredicate =
          pkg: builtins.elem (lib.getName pkg) config.nixpkgs.allowUnfreeNames;

        nixpkgs.overlays = [
          (final: _: {
            stable = import inputs.nixpkgs-stable {
              inherit (final.stdenv.hostPlatform) system;
              inherit (config.nixpkgs) config;
            };
          })
        ]
        ++ lib.flatten (
          map (
            input:

            let
              inherit (inputs.${input}) overlays;
            in

            map (overlay: overlays.${overlay}) (lib.attrNames overlays)
          ) (builtins.filter (input: inputs.${input} ? overlays) (builtins.attrNames inputs))
        );

        nix.settings = {
          extra-trusted-substituters = [
            "https://nix-community.cachix.org"
            "https://nixpkgs-wayland.cachix.org"
          ];
          extra-trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
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

        programs.nh = {
          enable = true;
          flake = lib.mkDefault "${config.self.mainUserHome}/flake";

          clean = {
            enable = true;
            dates = "daily";
            extraArgs = "--keep 10 --keep-since 7d";
          };
        };

        programs.direnv.enable = true;
      };
    };

  flake.homeModules.nix =
    args@{ lib, config, ... }:

    {
      options.nixpkgs.allowUnfreeNames = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
      };

      config =
        if args ? nixosConfig then
          { }
        else
          {
            nixpkgs.config.allowUnfreePredicate =
              pkg: builtins.elem (lib.getName pkg) config.nixpkgs.allowUnfreeNames;

            nixpkgs.overlays = [
              (final: _: {
                stable = import inputs.nixpkgs-stable {
                  inherit (final.stdenv.hostPlatform) system;
                  inherit (config.nixpkgs) config;
                };
              })
            ]
            ++ lib.flatten (
              map (
                input:

                let
                  inherit (inputs.${input}) overlays;
                in

                map (overlay: overlays.${overlay}) (lib.attrNames overlays)
              ) (builtins.filter (input: inputs.${input} ? overlays) (builtins.attrNames inputs))
            );
          };
    };
}
