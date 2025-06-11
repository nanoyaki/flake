{
  lib,
  whisparr,

  _sources,
}:

let
  inherit (lib) optionalAttrs versionOlder;
in

whisparr.overrideAttrs (
  optionalAttrs (versionOlder whisparr.version _sources.whisparr.version) {
    inherit (_sources.whisparr) version src;
  }
)
