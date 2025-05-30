{ config, pkgs, ... }:

{
  sec = {
    "restic/vaultwarden-local" = { };
    "restic/vaultwarden-remote/repo" = { };
    "restic/vaultwarden-remote/password" = { };
  };

  services.restic.backups = rec {
    vaultwarden-local = {
      initialize = true;
      repository = "/mnt/raid/backups/vaultwarden";
      passwordFile = config.sec."restic/vaultwarden-local".path;

      paths = [
        "/var/lib/vaultwarden"
        config.services.vaultwarden.backupDir
      ];

      environmentFile = "${pkgs.writeText "restic-env" "GOMAXPROCS=6"}";

      timerConfig = {
        OnCalendar = "*/3:00:00";
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

    vaultwarden-remote = vaultwarden-local // {
      repository = null;
      repositoryFile = config.sec."restic/vaultwarden-remote/repo".path;
      passwordFile = config.sec."restic/vaultwarden-remote/password".path;
    };
  };
}
