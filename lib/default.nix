{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./deps.nix
  ];

  _module.args.lib' = {
    # pkg -> attrs -> deriv
    overrideAppimageTools =
      pkg: finalAttrs:
      (pkg.override {
        appimageTools = pkgs.appimageTools // {
          wrapType2 = args: pkgs.appimageTools.wrapType2 (args // finalAttrs);
        };
      });

    # [ String ] -> deriv -> attrs
    mapDefaultForMimeTypes = pkg: mimeTypes: lib.genAttrs mimeTypes (_: "${lib.getName pkg}.desktop");

    # String -> String -> deriv
    mkProtonGeBin =
      version: hash:
      (pkgs.proton-ge-bin.overrideAttrs {
        inherit version;
        src = pkgs.fetchzip {
          url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
          inherit hash;
        };
      });

    # String -> String
    toUppercase =
      str:
      (lib.strings.toUpper (builtins.substring 0 1 str))
      + builtins.substring 1 (builtins.stringLength str) str;

    wrapEnvVars =
      pkg: variables:
      pkgs.writeShellScriptBin (pkg.pname or pkg.name) (
        let
          parsedEnvVars = builtins.concatStringsSep " " (
            lib.mapAttrsToList (name: value: "${name}=${value}") variables
          );
        in
        ''${parsedEnvVars} ${lib.getExe pkg}''
      );

    wrapEnvVars' =
      pkg: mainProgram: variables:
      pkgs.writeShellScriptBin (pkg.pname or pkg.name) (
        let
          parsedEnvVars = builtins.concatStringsSep " " (
            lib.mapAttrsToList (name: value: "${name}=\"${value}\"") variables
          );
        in
        ''${parsedEnvVars} ${lib.getExe' pkg mainProgram}''
      );

    mkEnabledOption = name: (lib.mkEnableOption name) // { default = true; };

    types.singleAttrOf =
      elemType:
      (lib.types.attrsOf elemType)
      // {
        check = actual: (lib.isAttrs actual) && ((lib.lists.length (lib.attrValues actual)) == 1);
      };
  };
}
