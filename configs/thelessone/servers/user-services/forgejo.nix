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
  sops.secrets = {
    "forgejo/users/nanoyaki".owner = cfg.user;
    "forgejo/runners/default".mode = "0444";
  };

  users.groups.${group} = { };

  users.users.${user} = {
    inherit group;

    home = cfg.stateDir;
    useDefaultShell = true;
    isSystemUser = true;
  };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;

    instances.default = {
      enable = false;
      name = "monolith";
      url = "https://git.theless.one";
      tokenFile = config.sops.secrets."forgejo/runners/default".path;

      labels = [ "native:host" ];
      hostPackages = with pkgs; [
        # defaults
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

        nix
        openssh
        statix
        nix-fast-build
        nvd
        inputs'.rebuild-maintenance.packages.rebuild-maintenance
      ];
    };
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

      service.DISABLE_REGISTRATION = true;

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };

      webhook.ALLOWED_HOST_LIST = "external,loopback";

      mailer.ENABLED = false;
    };
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

  systemd.services.restic-backups-forgejo-local.unitConfig.RequiresMountsFor = "/mnt/raid";

  config'.caddy.reverseProxies."git.theless.one" = {
    port = config.services.forgejo.settings.server.HTTP_PORT;
    serverAliases = [ "git.nanoyaki.space" ];
  };

  config'.homepage.categories.Code.services.Forgejo = rec {
    description = "Code forge";
    icon = "forgejo.svg";
    href = "https://git.theless.one";
    siteMonitor = href;
  };

  systemd.services.forgejo.preStart =
    let
      passwordFile = config.sops.secrets."forgejo/users/nanoyaki".path;
    in
    ''
      ${lib.getExe cfg.package} admin user create --admin --email "hanakretzer@gmail.com" --username "nanoyaki" --password "$(cat ${passwordFile})" || true
    '';
}
