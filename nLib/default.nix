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
    mapDefaultForMimeTypes = mimeTypes: pkg: lib.genAttrs mimeTypes (_: "${lib.getName pkg}.desktop");

    # string -> string -> deriv
    mkProtonGeBin =
      version: hash:
      (pkgs.proton-ge-bin.overrideAttrs {
        inherit version;
        src = pkgs.fetchzip {
          url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
          inherit hash;
        };
      });
  };
}
