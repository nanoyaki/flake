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
      inherit (lib)
        callPackageWith
        mapAttrs
        ;

      inherit (builtins)
        removeAttrs
        readDir
        ;

      callPackage = callPackageWith (
        pkgs
        // {
          _sources = pkgs.callPackage ./_sources/generated.nix { };
        }
      );
    in
    {
      overlayAttrs = config.packages;

      packages = mapAttrs (name: _: callPackage (./. + "/${name}") { }) (
        removeAttrs (readDir ./.) [
          "_sources"
          "default.nix"
        ]
      );
    };
}
