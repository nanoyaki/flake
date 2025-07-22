{
  pkgs,
  config,
  ...
}:

{

  sops.secrets."restic/smp" = { };

  services.restic.backups.smp = {
    initialize = true;
    repository = "/var/lib/restic/backups/smp";
    passwordFile = config.sops.secrets."restic/smp".path;

    paths = [ "${config.services.minecraft-servers.dataDir}/smp/world" ];
    exclude = [ "${config.services.minecraft-servers.dataDir}/smp/world/**/data/DistantHorizons*" ];

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
