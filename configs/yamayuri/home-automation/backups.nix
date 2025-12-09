{ config, ... }:

{
  sops.secrets = {
    id_yamayuri_borgbackup_postgres = { };
    id_yamayuri_borgbackup_hass = { };
  };

  services.borgbackup.jobs = {
    postgres = {
      user = "postgres";
      group = "postgres";

      # Keep CPU overhead low
      encryption.mode = "none";
      compression = "none";

      paths = "${config.services.postgresql.dataDir}/backup.sql";

      extraCreateArgs = "--verbose --list --stats --checkpoint-interval 600";
      extraArgs = "--progress";
      extraPruneArgs = "--stats --list --save-space";

      preHook = ''
        cd ${config.services.postgresql.dataDir}
        pg_dumpall > backup.sql
      '';

      # environment.BORG_RSH = "ssh -i ${config.sops.secrets.id_yamayuri_borgbackup_postgres.path}";
      # repo = "ssh://borg@10.101.0.4/moon/borgbackup/postgres";
      repo = "/var/backup/hass";
      readWritePaths = [ "/var/backup/hass" ];

      startAt = "*-*-* 5:0:0";

      prune.keep = {
        daily = 7;
        weekly = 13;
        monthly = -1;
      };
    };

    hass = {
      user = "hass";
      group = "hass";

      # Keep CPU overhead low
      encryption.mode = "none";
      compression = "none";

      paths = config.services.home-assistant.configDir;

      extraCreateArgs = "--verbose --list --stats --checkpoint-interval 600";
      extraArgs = "--progress";
      extraPruneArgs = "--stats --list --save-space";

      preHook = ''
        /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl stop home-assistant
      '';

      postCreate = ''
        /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl start home-assistant
      '';

      # environment.BORG_RSH = "ssh -i ${config.sops.secrets.id_yamayuri_borgbackup_hass.path}";
      # repo = "ssh://borg@10.101.0.4/moon/borgbackup/hass";
      repo = "/var/backup/hass";
      readWritePaths = [ "/var/backup/hass" ];

      startAt = "*-*-* 5:30:0";

      prune.keep = {
        daily = 7;
        weekly = 13;
        monthly = -1;
      };
    };
  };

  security.sudo.extraRules = [
    {
      users = [ "hass" ];
      groups = [ "hass" ];
      commands =
        map
          (command: {
            inherit command;
            options = [ "NOPASSWD" ];
          })
          [
            "/run/current-system/sw/bin/systemctl stop home-assistant"
            "/run/current-system/sw/bin/systemctl start home-assistant"
          ];
    }
  ];
}
