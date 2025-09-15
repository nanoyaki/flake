{ pkgs, config, ... }:

{
  sops.secrets = {
    vaultwarden-smtp-password = { };
    vaultwarden-admin-token = { };
  };
  sops.templates."vaultwarden.env" = {
    file = (pkgs.formats.keyValue { }).generate "vaultwarden.env.template" {
      SMTP_PASSWORD = config.sops.placeholder.vaultwarden-smtp-password;
      # ADMIN_TOKEN= "'${config.sops.placeholder.vaultwarden-admin-token}'";
    };
    restartUnits = [ "vaultwarden.service" ];
  };

  services.vaultwarden = {
    config = {
      SMTP_HOST = "mail.theless.one";
      SMTP_PORT = 465;

      SMTP_USERNAME = "vaultwarden@theless.one";
      SMTP_FROM = "vaultwarden@theless.one";
      SMTP_FROM_NAME = "Vaultwarden Theless.one";

      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      REQUIRE_DEVICE_EMAIL = true;

      ORG_CREATION_USERS = "hanakretzer@gmail.com";
    };

    environmentFile = config.sops.templates."vaultwarden.env".path;
  };

  config'.vaultwarden.enable = true;

  sops.secrets = {
    "restic/100-64-64-3" = { };
    "restic/vaultwarden-local" = { };
    "restic/vaultwarden-remote" = { };
  };

  sops.templates."restic-vauldwarden-repo.txt".content = ''
    rest:http://restic:${
      config.sops.placeholder."restic/100-64-64-3"
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
      passwordFile = config.sops.secrets."restic/vaultwarden-remote".path;
    };
  };
}
