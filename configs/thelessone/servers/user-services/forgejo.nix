{
  lib,
  pkgs,
  inputs',
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
    github-token.sopsFile = config.config'.sops.sharedSopsFile;
    "forgejo/runner" = { };
  };
  sops.templates."forgejo-runner-default.env".file =
    (pkgs.formats.keyValue { }).generate "forgejo-runner-default.env.template"
      {
        TOKEN = config.sops.placeholder."forgejo/runner";
        NIX_CONFIG = ''"extra-access-tokens = github.com=${config.sops.placeholder.github-token}"'';
      };

  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;

    instances.default = {
      enable = true;
      name = "monolith";
      url = "https://git.theless.one";
      tokenFile = config.sops.templates."forgejo-runner-default.env".path;

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
        (pkgs.symlinkJoin {
          name = "openssh-wrapped";
          paths = [ pkgs.openssh ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram "$out/bin/ssh" \
              --add-flags '"''${EXTRA_SSH_OPTS[@]}"'
          '';
        })
        statix
        nix-fast-build
        dix
        inputs'.rebuild-maintenance.packages.rebuild-maintenance
        inotify-tools
        nixos-rebuild
      ];
    };
  };

  systemd.tmpfiles.settings."10-forgejo"."/etc/forgejo".d = {
    inherit (cfg) user group;
    mode = "500";
  };

  sops.secrets = {
    "forgejo/signing".owner = cfg.user;
    "forgejo/signing.pub".owner = cfg.user;
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

      "repository.signing" = {
        FORMAT = "ssh";
        SIGNING_KEY = config.sops.secrets."forgejo/signing.pub".path;
        SIGNING_NAME = "forgejo git.theless.one";
        SIGNING_EMAIL = "hanakretzer+forgejo@gmail.com";
      };
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
