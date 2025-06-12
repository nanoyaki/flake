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
          _sources = callPackage ./_sources/generated.nix { };
          _versions = lib.importJSON ./versions.json;
        }
      );
    in
    {
      overlayAttrs = config.packages;

      packages =
        (mapAttrs (name: _: callPackage (./. + "/${name}") { }) (
          removeAttrs (readDir ./.) [
            "_sources"
            "versions.json"
            "default.nix"
          ]
        ))
        // rec {
          suwayomi-server = callPackage ./suwayomi-server { inherit suwayomi-webui; };
          suwayomi-webui = callPackage ./suwayomi-webui { };
          shoko = callPackage ./shoko { };
          shoko-webui = callPackage ./shoko-webui { inherit shoko; };
        };
    };
}
