{
  config,
  ...
}:

{
  sops.secrets."restic/smp" = { };

  config'.restic.backups.smp = {
    repository = "/mnt/raid/backups/smp";
    passwordFile = config.sops.secrets."restic/smp".path;

    basePath = config.services.minecraft-servers.dataDir;
    paths = [ "smp/world" ];
    exclude = [
      "smp/world/**/data/DistantHorizons*"
      "smp/world/datapacks"
      "smp/world/**/*.bak"
    ];

    timerConfig.OnCalendar = "*:0/30";
  };

  systemd.services.restic-backups-smp.unitConfig.RequiresMountsFor = "/mnt/raid";
}
