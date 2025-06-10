{
  lib,
  lidarr,

  _sources,
}:

let
  inherit (lib) optionalAttrs versionOlder;
in

lidarr.overrideAttrs (
  optionalAttrs (versionOlder lidarr.version _sources.lidarr.version) {
    inherit (_sources.lidarr) version src;
  }
)
