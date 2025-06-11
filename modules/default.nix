{
  self,
  lib,
  lib',
  ...
}:

let
  inherit (lib)
    filterAttrs
    flatten
    attrNames
    removeSuffix
    map
    nameValuePair
    ;

  inherit (builtins)
    stringLength
    readDir
    listToAttrs
    ;
in

{
  flake.nixosModules =
    listToAttrs (
      flatten (
        map
          (
            dir:
            let
              files = readDir (./by-name + "/${dir}");
            in
            map (
              name:
              nameValuePair (if files.${name} == "directory" then name else removeSuffix ".nix" name) (
                import (./by-name + "/${dir}/${name}") { inherit self lib lib'; }
              )
            ) (attrNames files)
          )
          (
            attrNames (
              filterAttrs (dir: type: (stringLength dir) < 3 && type == "directory") (readDir ./by-name)
            )
          )
      )
    )
    // {
      suwayomi = import ./suwayomi;
    };
}
# meow
