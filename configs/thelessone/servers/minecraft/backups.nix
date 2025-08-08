{
  pkgs,
  config,
  ...
}:

let
  dataDirPaths =
    relativePaths: map (path: "${config.services.minecraft-servers.dataDir}/${path}") relativePaths;
in

{
  sops.secrets."restic/smp" = { };

  services.restic.backups.smp = {
    initialize = true;
    repository = "/var/lib/restic/backups/smp";
    passwordFile = config.sops.secrets."restic/smp".path;

    paths = dataDirPaths [ "smp/world" ];
    exclude = dataDirPaths [
      "smp/world/**/data/DistantHorizons*"
      "smp/world/datapacks"
      "smp/world/**/*.bak"
    ];

    environmentFile = ''${pkgs.writeText "restic-smp-env" ''
      GOMAXPROCS=6
    ''}'';

    timerConfig = {
      OnCalendar = "*:0/30";
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
  };

  systemd.tmpfiles.settings."10-restic-backups"."/var/lib/restic/backups".d = {
    mode = "0700";
    user = "root";
    group = "wheel";
  };
}
