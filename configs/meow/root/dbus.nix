{ lib, config, ... }:

let
  inherit (lib) mkOption types mkIf;

  cfg = config.services.dbus.packages;

  dbusPaths = [
    "etc/dbus-1/system.d"
    "share/dbus-1/system.d"
    "share/dbus-1/system-services"
    "etc/dbus-1/session.d"
    "share/dbus-1/session.d"
    "share/dbus-1/services"
  ];

  mapDbusFiles =
    package: path:
    let
      files = lib.attrsets.attrNames (
        lib.attrsets.filterAttrs (_: value: value == "regular") (builtins.readDir "${package}/${path}")
      );
    in
    lib.map (file: {
      name = if lib.hasPrefix "etc/" path then "/${path}/${file}" else "/usr/${path}/${file}";
      value.source = "${package}/${path}/${file}";
    }) files;

  collectDbusFiles =
    package:
    lib.lists.concatMap (
      path: lib.lists.optional (builtins.pathExists "${package}/${path}") (mapDbusFiles package path)
    ) dbusPaths;
in

{
  options.services.dbus.packages = mkOption {
    type = types.listOf types.path;
    default = [ ];
    description = ''
      Packages whose D-Bus configuration files should be included in
      the configuration of the D-Bus system-wide or session-wide
      message bus.  Specifically, files in the following directories
      will be included into their respective DBus configuration paths:
      {file}`«pkg»/etc/dbus-1/system.d`
      {file}`«pkg»/share/dbus-1/system.d`
      {file}`«pkg»/share/dbus-1/system-services`
      {file}`«pkg»/etc/dbus-1/session.d`
      {file}`«pkg»/share/dbus-1/session.d`
      {file}`«pkg»/share/dbus-1/services`
    '';
  };

  config = mkIf (cfg != [ ]) {
    assertions = [
      {
        assertion = lib.lists.all (
          package: lib.lists.any (dbusPath: builtins.pathExists "${package}/${dbusPath}") dbusPaths
        ) cfg;
        message = "Dbus packages must contain any of the valid paths listed in the description of the {option}`services.dbus.packages` option";
      }
    ];

    home.file = lib.attrsets.listToAttrs (lib.lists.flatten (lib.lists.map collectDbusFiles cfg));
  };
}
