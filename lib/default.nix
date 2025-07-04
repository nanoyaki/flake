{
  self,
  lib,
  inputs,
  withSystem,
  ...
}:
{
  _module.args = rec {
    lib' =
      {
        # [ String ] -> deriv -> attrs
        mapDefaultForMimeTypes = pkg: mimeTypes: lib.genAttrs mimeTypes (_: "${lib.getName pkg}.desktop");

        # String -> String
        toUppercase =
          str:
          (lib.strings.toUpper (builtins.substring 0 1 str))
          + builtins.substring 1 (builtins.stringLength str) str;

        mkEnabledOption = name: (lib.mkEnableOption name) // { default = true; };

        mkSystem =
          {
            hostname,
            modules,
            username,
            platform ? "x86_64-linux",
          }:

          {
            ${hostname} = withSystem platform (
              {
                inputs',
                self',
                ...
              }:

              inputs.nixpkgs.lib.nixosSystem {
                specialArgs = {
                  inherit (inputs'.nanopkgs) packages;
                  inherit
                    inputs
                    inputs'
                    username
                    self
                    self'
                    ;

                  lib' = lib' // {
                    mapLazyApps = lazyApp: map inputs'.lazy-apps.packages.lazy-app.override lazyApp;
                  };
                };

                modules = [
                  {
                    options.config'.explicitDependencies = lib'.options.mkTrueOption;

                    config = { };
                  }
                  {
                    networking.hostName = hostname;
                    nixpkgs.hostPlatform.system = platform;
                  }
                ] ++ modules;
              }
            );
          };
      }
      // import ./types.nix { inherit lib lib'; }
      // import ./modules.nix { inherit lib lib'; }
      // import ./options.nix { inherit lib lib'; };
  };
}
