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
    default = { };
  };

  config.flake.overlays = mapAttrs (
    _: overlay: final: prev:

    withSystem prev.stdenv.hostPlatform.system (systemArgs: overlay final prev systemArgs)
  ) config.overlays;
}
