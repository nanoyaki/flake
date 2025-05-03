{
  lib,
  ...
}:

{
  flake.nixosModules = lib.mapAttrs (name: _: import (./. + "/${name}")) (
    lib.filterAttrs (_: value: value == "directory") (builtins.readDir ./.)
  );
}
