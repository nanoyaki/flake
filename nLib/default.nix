{
  withSystem,
  inputs,
  pkgs,
  ...
}:
{
  _module.args.nLib = {
    mkSystem =
      {
        hostname,
        modules,
        username ? "hana",
        platform ? "x86_64-linux",
      }:

      {
        "${hostname}" = withSystem platform (
          {
            config,
            inputs',
            ...
          }:

          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit
                inputs
                inputs'
                username
                ;

              packages = config.packages;
            };

            modules = [
              {
                networking.hostName = hostname;
                nixpkgs.hostPlatform.system = platform;
              }
            ] ++ modules;
          }
        );
      };

    # pkg -> attrs -> deriv
    overrideAppimageTools =
      pkg: finalAttrs:
      (pkg.override {
        appimageTools = pkgs.appimageTools // {
          wrapType2 = args: pkgs.appimageTools.wrapType2 (args // finalAttrs);
        };
      });
  };
}
