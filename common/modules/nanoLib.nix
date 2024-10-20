{
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types;
in

{
  options.nanoLib = mkOption {
    type = types.attrs;
  };

  config.nanoLib = {
    overrideAppimageTools =
      pkg: finalAttrs:
      (pkg.override {
        appimageTools = pkgs.appimageTools // {
          wrapType2 = args: pkgs.appimageTools.wrapType2 (args // finalAttrs);
        };
      });
  };
}
