{
  withSystem,
  inputs,
  lib,
  self,
  ...
}:

let
  inherit (inputs) nixpkgs;
  inherit (builtins) map;
in

{
  _module.args = rec {
    lib' = {
      # Primitive, do not use
      _mkSystem =
        type:

        {
          hostname,
          users,
          platform ? "x86_64-linux",
          config,
        }:

        (withSystem platform (
          { inputs', self', ... }:

          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit
                inputs'
                inputs
                self'
                self
                ;

              lib' = lib' // (lib'.systemSpecific platform);
            };

            modules = [
              self.nixosModules.all
              (import ../modules/systems/all { inherit hostname users platform; })
              (../modules/systems + "/${type}")
              config
            ];
          }
        ));

      # No UI applications
      mkHeadless = lib'._mkSystem "headless";
      # Deployment options
      mkServer = lib'._mkSystem "server";
      # Full suite of UI applications
      mkDesktop = lib'._mkSystem "desktop";
      # Prefer power efficiency
      mkPortable = lib'._mkSystem "portable";

      toUppercase =
        str:
        (lib.strings.toUpper (builtins.substring 0 1 str))
        + builtins.substring 1 (builtins.stringLength str) str;

      options = import ./options.nix { inherit lib lib'; };
      types = import ./types.nix { inherit lib lib'; };
      systemSpecific =
        system:
        withSystem system (
          { inputs', ... }:

          {
            mapLazyApps = pkgs: map inputs'.lazy-apps.packages.lazy-app.override pkgs;
            mapLazyCliApps =
              pkgs: map (pkg: inputs'.lazy-apps.packages.lazy-app.override { inherit pkg; }) pkgs;
          }
        );
    };
  };
}
