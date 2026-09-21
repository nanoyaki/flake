{
  lib,
  withSystem,
  config,
  ...
}:

let
  inherit (lib) mkOption types mapAttrs;

  overlayType = lib.mkOptionType {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };
in

{
  options.overlays = mkOption {
    type = types.lazyAttrsOf overlayType;
    apply = mapAttrs (
      _: overlay: _final: prev:

      withSystem prev.stdenv.hostPlatform.system overlay
    );
    default = { };
  };

  config.flake.overlays = config.overlays;
}
