{
  lib,
  lib',
  pkgs,
  config,
  options,
  ...
}:

let
  inherit (lib)
    recursiveUpdate
    removeAttrs
    attrNames
    mapAttrs'
    nameValuePair
    types
    mkOption
    ;
  inherit (lib'.options)
    mkAttrsOf
    mkPathOption
    ;

  baseTypes =
    with types;
    oneOf [
      attrs
      str
      int
      bool
    ];

  cfg = config.config'.restic.backups;
  opt = options.config'.restic.backups;

  extraOptions = mkOption {
    type = types.submodule {
      freeformType = with types; nullOr (either baseTypes (listOf baseTypes));

      options.basePath = mkPathOption;
    };
    default = { };
  };
in

{
  options.config'.restic.backups = mkAttrsOf extraOptions;

  config = {
    services.restic.backups = mapAttrs' (
      name: bacCfg:
      let
        baseConfig = removeAttrs bacCfg (attrNames (opt.type.getSubOptions opt.type.getSubModules));
        finalConfig = baseConfig // {
          paths =
            if bacCfg ? paths then
              map (path: "${bacCfg.basePath}/${path}") bacCfg.paths
            else
              [ bacCfg.basePath ];
          exclude = if bacCfg ? exclude then map (path: "${bacCfg.basePath}/${path}") bacCfg.exclude else [ ];
        };
      in
      nameValuePair name (
        recursiveUpdate {
          initialize = true;
          environmentFile = toString (pkgs.writeText "restic-env" "GOMAXPROCS=6\n");

          timerConfig = {
            OnCalendar = "hourly";
            Persistent = true;
            RandomizedDelaySec = "30s";
          };

          pruneOpts = [
            "--keep-last 3"
            "--keep-hourly 24"
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 6"
            "--keep-yearly 2"
          ];
        } finalConfig
      )
    ) cfg;
  };
}
