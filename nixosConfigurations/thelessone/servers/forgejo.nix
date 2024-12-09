{ lib, config, ... }:

let
  cfg = config.services.forgejo;
in

{
  sops.secrets."forgejo/users/nanoyaki".owner = cfg.user;

  services.forgejo = {
    enable = true;
    lfs.enable = true;

    database.type = "postgres";

    settings = {
      server = {
        DOMAIN = "git.theless.one";
        ROOT_URL = "https://${cfg.settings.server.DOMAIN}/";
        HTTP_PORT = 12500;
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
