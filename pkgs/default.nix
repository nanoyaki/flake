{ inputs, ... }:

{
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      callPackage = lib.callPackageWith (
        pkgs
        // {
          _sources = pkgs.callPackage ./_sources/generated.nix { };
        }
      );
    in
    {
      overlayAttrs = config.packages;

      packages = {
        startvrc = callPackage ./startvrc { };
        writeSystemdToggle = callPackage ./writeSystemdToggle { };
        pyon = callPackage ./pyon { };
        midnight-theme = callPackage ./midnight-theme { };
        amdgpu-i2c = callPackage ./amdgpu-i2c { };
        openrgb-latest = callPackage ./openrgb { };
        meow = callPackage ./meow { };
      };
    };
}
