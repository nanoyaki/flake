{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkOption types mkIf;

  cfg = config.systemd.services;

  toSystemdIni = lib.generators.toINI {
    listsAsDuplicateKeys = true;
    mkKeyValue =
      key: value:
      let
        value' =
          if builtins.isBool value then (if value then "true" else "false") else builtins.toString value;
      in
      "${key}=${value'}";
  };

  mkPathSafeName = lib.replaceStrings [ "@" ":" "\\" "[" "]" ] [ "-" "-" "-" "" "" ];

  buildService =
    name: serviceCfg:
    let
      filename = "${name}.service";
      pathSafeName = mkPathSafeName filename;

      # Needed because systemd derives unit names from the ultimate
      # link target.
      source =
        pkgs.writeTextFile {
          name = pathSafeName;
          text = toSystemdIni serviceCfg;
          destination = "/${filename}";
        }
        + "/${filename}";

      install = variant: target: {
        name = "/etc/systemd/system/${target}.${variant}/${filename}";
        value = { inherit source; };
      };
    in
    lib.singleton {
      name = "/etc/systemd/system/${filename}";
      value = { inherit source; };
    }
    ++ map (install "wants") (serviceCfg.Install.WantedBy or [ ])
    ++ map (install "requires") (serviceCfg.Install.RequiredBy or [ ]);
in

{
  options.systemd.services = mkOption {
    type =
      with types;
      let
        primitive = oneOf [
          bool
          int
          str
          path
        ];
      in
      attrsOf (attrsOf (attrsOf (either primitive (listOf primitive))))
      // {
        description = "systemd service unit configuration";
      };
    default = { };
  };

  config = mkIf (cfg != { }) {
    home.file = lib.listToAttrs (
      lib.lists.flatten (lib.map (service: buildService service cfg.${service}) (lib.attrNames cfg))
    );
  };
}
