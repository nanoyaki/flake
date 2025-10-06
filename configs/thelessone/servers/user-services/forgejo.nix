{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.services.forgejo;

  user = "git";
  group = "git";
in

{
  users.groups.${group} = { };

  users.users.${user} = {
    inherit group;

    home = cfg.stateDir;
    useDefaultShell = true;
    isSystemUser = true;
  };

  sops.secrets = {
    "forgejo/kikyo" = { };
    "forgejo/syakuyaku" = { };
  };

  sops.templates."kikyo.env".content = ''
    TOKEN=${config.sops.placeholder."forgejo/kikyo"}
  '';

  sops.templates."syakuyaku.env".content = ''
    TOKEN=${config.sops.placeholder."forgejo/syakuyaku"}
  '';

  systemd.services.gitea-runner-kikyo.environment = {
    inherit (config.environment.sessionVariables) NIX_PATH;
  };

  systemd.services.gitea-runner-syakuyaku.environment = {
    inherit (config.environment.sessionVariables) NIX_PATH;
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;

    instances = rec {
      kikyo = {
        enable = true;
        name = "kikyo";
        url = "https://git.theless.one";
        tokenFile = config.sops.templates."kikyo.env".path;

        labels = [ "native:host" ];
        hostPackages = with pkgs; [
          # essentials
          bash
          coreutils
          curl
          gawk
          git
          git-lfs
          gnused
          nodejs
          wget
          which
          iputils
          tea

          nix
          openssh
          statix
          nix-fast-build
          dix
          inotify-tools
          nh
        ];
      };

      syakuyaku = kikyo // {
        name = "syakuyaku";
        tokenFile = config.sops.templates."syakuyaku.env".path;
      };
    };
  };

  systemd.tmpfiles.settings."10-forgejo"."/etc/forgejo".d = {
    inherit (cfg) user group;
    mode = "500";
  };

  sops.secrets = {
    "forgejo/signing".owner = cfg.user;
    "forgejo/signing.pub".owner = cfg.user;
    "forgejo/mailer-password".owner = cfg.user;
  };

  services.forgejo = {
    enable = true;
    lfs.enable = true;
    package = pkgs.forgejo;

    inherit user group;
    stateDir = "/var/lib/${user}";

    database = {
      inherit user;

      name = user;
      type = "postgres";
    };

    dump = {
      enable = true;
      interval = "hourly";
      file = "forgejo-backup-dump";
      type = "tar";
    };

    settings = {
      server = {
        DOMAIN = "git.theless.one";
        ROOT_URL = "https://${cfg.settings.server.DOMAIN}/";
        HTTP_PORT = 12500;

        DISABLE_SSH = false;
      };

      service = {
        DISABLE_REGISTRATION = true;
        ENABLE_NOTIFY_MAIL = true;
      };

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };

      webhook.ALLOWED_HOST_LIST = "external,loopback";

      mailer = {
        ENABLED = true;
        FROM = "git@theless.one";
        PROTOCOL = "smtps";
        SMTP_ADDR = "mail.theless.one";
        SMTP_PORT = 465;
        USER = "git@theless.one";
      };

      "repository.signing" = {
        FORMAT = "ssh";
        SIGNING_KEY = config.sops.secrets."forgejo/signing.pub".path;
        SIGNING_NAME = "forgejo git.theless.one";
        SIGNING_EMAIL = "git@theless.one";
      };
    };

    secrets.mailer.PASSWD = config.sops.secrets."forgejo/mailer-password".path;
  };

  sops.secrets = {
    "restic/100-64-64-3" = { };
    "restic/forgejo-local" = { };
    "restic/forgejo-remote" = { };
  };

  sops.templates."restic-forgejo-repo.txt".content = ''
    rest:http://restic:${
      config.sops.placeholder."restic/100-64-64-3"
    }@100.64.64.3:8000/forgejo-thelessone
  '';

  config'.restic.backups = rec {
    forgejo-local = {
      repository = "/mnt/raid/backups/forgejo";
      passwordFile = config.sops.secrets."restic/forgejo-local".path;

      basePath = config.services.forgejo.dump.backupDir;
      paths = [ "forgejo-backup-dump.tar" ];

      timerConfig.OnCalendar = "*-*-* *:05:00";
    };

    forgejo-remote = forgejo-local // {
      repository = null;
      repositoryFile = config.sops.templates."restic-forgejo-repo.txt".path;
      passwordFile = config.sops.secrets."restic/forgejo-remote".path;
    };
  };

  config'.caddy.vHost."git.theless.one".proxy.port =
    config.services.forgejo.settings.server.HTTP_PORT;

  config'.homepage.categories.Code.services.Forgejo = rec {
    description = "Code forge";
    icon = "forgejo.svg";
    href = "https://git.theless.one";
    siteMonitor = href;
  };

  sops.secrets."forgejo/users/nanoyaki".owner = cfg.user;
  systemd.services.forgejo.preStart =
    let
      passwordFile = config.sops.secrets."forgejo/users/nanoyaki".path;
    in
    ''
      ${lib.getExe cfg.package} admin user create --admin --email "hanakretzer@gmail.com" --username "nanoyaki" --password "$(cat ${passwordFile})" || true
    '';
}
