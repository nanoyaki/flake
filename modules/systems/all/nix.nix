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
  inherit (lib) mkPackageOption concatStringsSep attrNames;
  inherit (lib'.options) mkNullOr mkPathOption;

  cfg = config.config'.nix;

  findCmds = map (
    username:
    ''find ${
      config.users.users.${username}.home
    } -name "*.${config.home-manager.backupFileExtension}" -delete''
  ) (attrNames config.config'.users);
in

{
  options.config'.nix = {
    flakeDir = mkNullOr mkPathOption;
    rebuildScript = mkPackageOption pkgs "rb" { };
  };

  config = {
    nixpkgs.overlays = [
      (final: _: {
        stable = import nixpkgs-stable {
          inherit (final.stdenv.hostPlatform) system;
          inherit (config.nixpkgs) config;
        };
        rb = final.writeShellApplication {
          name = "rb";
          runtimeInputs = with final; [
            nix-fast-build
            nixos-rebuild
          ];
          text = ''
            set -eo pipefail

            if [[ $EUID -ne 0 ]]; then
              echo "Script requires root priviledges."
              exit 1
            fi

            nix-fast-build --eval-workers 4 --out-link result \
              -f ${config.config'.nix.flakeDir}#nixosConfigurations."$(hostname)".config.system.build.toplevel

            echo "Deleting home-manager backups..."
            ${concatStringsSep "\n" findCmds}

            echo "Adding system profile..."
            NEWEST_GEN="$(nixos-rebuild list-generations | awk 'NR==2 {print $1}')";
            BUILT_GEN="$((NEWEST_GEN + 1))"

            sudo ln -s "$(readlink -f ./result-)" /nix/var/nix/profiles/system-$BUILT_GEN-link

            echo "Switching system profile..."
            nix-env --profile /nix/var/nix/profiles/system --switch-generation $BUILT_GEN

            echo "Running switch-to-configuration switch..."
            ./result-/bin/switch-to-configuration switch

            echo "Set boot entry..."
            ./result-/bin/switch-to-configuration boot

            echo "Deleting result link..."
            rm -rf "./result-"

            echo -e 'Done. \033[38;5;219m\U2665\033[0m'
          '';
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

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 14d";
        randomizedDelaySec = "15min";
        persistent = true;
      };

      registry = {
        self.flake = self;
      }
      // lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    };

    # rebuilding purposes
    config'.nix.flakeDir = lib.mkDefault "${config.hm.home.homeDirectory}/flake";
    environment.sessionVariables.FLAKE_DIR = cfg.flakeDir;
    programs.direnv.enable = true;
    environment.systemPackages = [
      pkgs.nix-fast-build
      cfg.rebuildScript
    ];
  };
}
