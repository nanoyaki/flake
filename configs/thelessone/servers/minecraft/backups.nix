{
  lib,
  pkgs,
  config,
  ...
}:

{

  sec."restic/smp" = { };

  services.restic.backups.smp = {
    initialize = true;
    repository = "/var/lib/restic/backups/smp";
    passwordFile = config.sec."restic/smp".path;

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

    backupPrepareCommand = lib.getExe (
      pkgs.writeShellApplication {
        name = "backupPrepareCommandSmp";
        runtimeInputs = with pkgs; [
          coreutils-full
          tmux
        ];
        text = ''
          systemctl is-active minecraft-server-smp.service --quiet && \
          date +%s > /tmp/minecraftServerSmpBackupStartTime
          tmux -S /run/minecraft/smp.sock send-keys \
            'tellraw @a ["",{"text":"['"$(date -d "@$(cat /tmp/minecraftServerSmpBackupStartTime)" +"%d.%m.%Y %H:%M")"'] ","color":"white"},{"text":"Backup gestartet","color":"dark_red","clickEvent":{"action":"open_url","value":"https://tinyurl.com/n7rn4dbh"},"hoverEvent":{"action":"show_text","contents":[{"text":"Free V-Bucks","color":"aqua"}]}}]' \
            Enter
        '';
      }
    );
    backupCleanupCommand = lib.getExe (
      pkgs.writeShellApplication {
        name = "backupCleanupCommandSmp";
        runtimeInputs = with pkgs; [
          coreutils-full
          tmux
        ];
        text = ''
          systemctl is-active minecraft-server-smp.service --quiet && \
          tmux -S /run/minecraft/smp.sock send-keys \
            'tellraw @a ["",{"text":"['"$(date +"%d.%m.%Y %H:%M")"'] ","color":"white"},{"text":"Backup vollendet","bold":true,"color":"green","hoverEvent":{"action":"show_text","contents":[{"text":"'"$(date -d "@$(( "$(date +%s)" - "$(cat /tmp/minecraftServerSmpBackupStartTime)" ))" +"%M:%S")"'m gebraucht. Das Backup verbraucht nun '"$(du -bsh /var/lib/restic/backups/smp | cut -f1)"'","color":"green"}]}}]' \
            Enter
        '';
      }
    );

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
