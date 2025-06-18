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
        splitString
        drop
        importJSON
        foldr
        setAttrByPath
        recursiveUpdate
        ;

      inherit (builtins)
        removeAttrs
        readDir
        elemAt
        attrNames
        ;

      callPackage = callPackageWith (
        pkgs
        // (
          let
            versions = (importJSON ./_versions/new_versions.json).data;
          in
          {
            _sources = callPackage ./_sources/generated.nix { };
            _versions = foldr (
              name: attrs:
              let
                sets = splitString "." name;
                set = elemAt sets 0;
                subsetPath = drop 1 sets;
              in
              recursiveUpdate attrs {
                ${set} = setAttrByPath subsetPath versions.${name}.version;
              }
            ) { } (attrNames versions);
          }
        )
      );
    in
    {
      overlayAttrs = config.packages;

      packages =
        (mapAttrs (name: _: callPackage (./. + "/${name}") { }) (
          removeAttrs (readDir ./.) [
            "_sources"
            "_versions"
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
