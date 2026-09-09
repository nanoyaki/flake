{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.postgresql ];
  };

  modules.nixos.postgresql = {
    services.postgresql.enable = true;
  };

  modules.nixos.rustic =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    let
      inherit (lib) mkIf;

      cfg = config.services.postgresql;
    in

    {
      config = mkIf cfg.enable {
        services.rustic.backups.postgresql = {
          command =
            (pkgs.writeShellScript "rustic-postgresql-stdout.sh" ''
              cd ${config.services.postgresql.dataDir} &> /dev/null
              pg_dumpall
            '').outPath;
        };
      };
    };
}
