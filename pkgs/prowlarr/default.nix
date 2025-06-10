{
  lib,
  prowlarr,

  _sources,
}:

let
  inherit (lib) optionalAttrs versionOlder;
in

prowlarr.overrideAttrs (
  optionalAttrs (versionOlder prowlarr.version _sources.prowlarr.version) {
    inherit (_sources.prowlarr) version src;
  }
)
