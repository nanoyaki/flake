{ lib, config, ... }:

let
  inherit (lib) mkOption types mkIf;

  cfg = config.home;

  mapFiles =
    package: path: mappedPath:
    let
      entries = builtins.readDir "${package}/${path}";
      handleEntry =
        name: type:
        if type != "directory" then
          [
            {
              name = "${mappedPath}/${path}/${name}";
              value.source = "${package}/${path}/${name}";
            }
          ]
        else
          mapFiles package "${path}/${name}" "${mappedPath}";
    in
    lib.lists.flatten (lib.attrsets.mapAttrsToList handleEntry entries);

  pathMapType = types.attrsOf types.path;
in

{
  options.home.mappedPaths = mkOption {
    type = types.either pathMapType (types.attrsOf pathMapType);
    default = { };
    example = lib.literalExpression ''
      {
        "bin" = "/bin";
        "share/polkit-1" = "/usr/share/polkit-1";
        "etc/polkit-1" = "/etc/polkit-1";
      }
    '';
    description = ''
      Map paths from packages to different locations in the root directory.
      Can either be a direct mapping or a nested attribute set for package specific mappings.
    '';
  };

  config = mkIf (cfg.mappedPaths != { }) {
    # assertions = [
    #   {
    #     assertion = lib.lists.all (
    #       mappedPath: types.path.check mappedPath && builtins.pathExists mappedPath
    #     ) (builtins.attrValues cfg.mappedPaths);
    #     message = ''
    #       Invalid path mappings in home.mappedPaths. Each mapping must be valid paths or strings.
    #       See the example for correct usage.
    #     '';
    #   }
    # ];

    home.file = lib.listToAttrs (
      lib.lists.flatten (
        lib.attrsets.mapAttrsToList (
          path: mappedPath:
          lib.lists.map (
            package:
            lib.lists.optional (builtins.pathExists "${package}/${path}") (mapFiles package path mappedPath)
          ) cfg.packages
        ) cfg.mappedPaths
      )
    );
  };
}
