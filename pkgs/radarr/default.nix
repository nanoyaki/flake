{
  lib,
  radarr,

  _sources,
}:

let
  inherit (lib) optionalAttrs versionOlder;
in

radarr.overrideAttrs (
  optionalAttrs (versionOlder radarr.version _sources.radarr.version) {
    inherit (_sources.radarr) version src;
  }
)
