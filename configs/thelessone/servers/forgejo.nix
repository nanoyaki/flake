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
  sec = {
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
      enable = true;
      name = "monolith";
      url = "https://git.theless.one";
      tokenFile = config.sec."forgejo/runners/default".path;

      labels = [ "native:host" ];
      hostPackages = with pkgs; [
        # defaults
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        nodejs
        wget

        # extra
        nix
        openssh
      ];
    };
  };

  services.forgejo = {
    enable = true;
    lfs.enable = true;

    inherit user group;
    stateDir = "/var/lib/${user}";

    database = {
      inherit user;

      name = user;
      type = "postgres";
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

      mailer.ENABLED = false;
    };
  };

  systemd.services.forgejo.preStart =
    let
      adminCmd = "${lib.getExe cfg.package} admin user";
      passwordFile = config.sops.secrets."forgejo/users/nanoyaki".path;
    in
    ''
      ${adminCmd} create --admin --email "hanakretzer@gmail.com" --username "nanoyaki" --password "$(cat ${passwordFile})" || true
    '';
}
