{ pkgs, config, ... }:

{
  sops.secrets.vaultwarden-smtp-password.owner = "vaultwarden";
  sops.templates."vaultwarden.env".file = (pkgs.formats.keyValue { }).generate "vaultwarden.env" {
    SMTP_PASSWORD = config.sops.placeholder.vaultwarden-smtp-password;
  };

  services.vaultwarden = {
    config = {
      SMTP_HOST = "smtp.gmail.com";
      SMTP_PORT = 587;
      SMTP_SECURITY = "starttls";

      SMTP_USERNAME = "hanakretzer@gmail.com";
      SMTP_FROM = "hanakretzer+vaultwarden@gmail.com";
      SMTP_FROM_NAME = "${config.config'.caddy.baseDomain} Vaultwarden Server";

      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      REQUIRE_DEVICE_EMAIL = true;

      ORG_CREATION_USERS = "hanakretzer@gmail.com";
    };

    environmentFile = config.sops.templates."vaultwarden.env".path;
  };

  config'.vaultwarden.enable = true;

  sops.secrets = {
    "restic/vaultwarden-local" = { };
    "restic/vaultwarden-remote/repo-pw" = { };
    "restic/vaultwarden-remote/password" = { };
  };

  sops.templates."restic-vauldwarden-repo.txt".content = ''
    rest:http://restic:${
      config.sops.placeholder."restic/vaultwarden-remote/repo-pw"
    }@100.64.64.3:8000/vaultwarden-thelessone
  '';

  config'.restic.backups = rec {
    vaultwarden-local = {
      repository = "/mnt/raid/backups/vaultwarden";
      passwordFile = config.sops.secrets."restic/vaultwarden-local".path;

      paths = [
        "/var/lib/vaultwarden"
        config.services.vaultwarden.backupDir
      ];

      timerConfig.OnCalendar = "*-*-* 00/3:00:00";
    };

    vaultwarden-remote = vaultwarden-local // {
      repository = null;
      repositoryFile = config.sops.templates."restic-vauldwarden-repo.txt".path;
      passwordFile = config.sops.secrets."restic/vaultwarden-remote/password".path;
    };
  };

  systemd.services.restic-backups-vaultwarden-local.unitConfig.RequiresMountsFor = "/mnt/raid";
}
