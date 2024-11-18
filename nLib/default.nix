{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./deps.nix
  ];

  _module.args.nLib = {
    # pkg -> attrs -> deriv
    overrideAppimageTools =
      pkg: finalAttrs:
      (pkg.override {
        appimageTools = pkgs.appimageTools // {
          wrapType2 = args: pkgs.appimageTools.wrapType2 (args // finalAttrs);
        };
      });

    # [ string ] -> deriv -> attrs
    mapDefaultForMimeTypes = mimeTypes: package: lib.genAttrs mimeTypes "${package.pname}.desktop";
  };
}
