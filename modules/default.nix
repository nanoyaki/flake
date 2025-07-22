{
  self,
  lib,
  ...
}:

let
  inherit (lib)
    filterAttrs
    flatten
    attrNames
    removeSuffix
    map
    ;

  inherit (builtins)
    stringLength
    readDir
    listToAttrs
    ;

  nixosModules = listToAttrs (
    flatten (
      map
        (
          dir:
          let
            files = readDir (./by-name + "/${dir}");
          in
          map (filename: {
            name = if files.${filename} == "directory" then filename else removeSuffix ".nix" filename;
            value = import (./by-name + "/${dir}/${filename}");
          }) (attrNames files)
        )
        (
          attrNames (
            filterAttrs (dir: type: (stringLength dir) < 3 && type == "directory") (readDir ./by-name)
          )
        )
    )
  );
in

{
  flake.nixosModules = {
    all =
      { ... }:

      {
        imports = map (moduleName: self.nixosModules.${moduleName}) (attrNames nixosModules);
      };

    # maybe i'll migrate this when i'm less lazy
    vr = import ./vr;
  }
  // nixosModules;
}
