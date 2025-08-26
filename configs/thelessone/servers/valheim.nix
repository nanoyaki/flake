{
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (inputs) valheim-server;
in

{
  imports = [ valheim-server.nixosModules.default ];

  sops.secrets = {
    valheim-password = { };
    "restic/valheim" = { };
  };

  sops.templates."valheim-password.env".file =
    (pkgs.formats.keyValue { }).generate "valheim-password.env.template"
      {
        VH_SERVER_PASSWORD = config.sops.placeholder.valheim-password;
      };

  services.valheim = {
    enable = true;
    openFirewall = true;
    passwordEnvFile = config.sops.templates."valheim-password.env".path;

    noGraphics = true;
    public = true;
    serverName = "Cozy server x3";
    worldName = "Test12";
    adminList = [ "76561198294979887" ];
  };

  config'.restic.backups.valheim = {
    repository = "/mnt/raid/backups/valheim";
    passwordFile = config.sops.secrets."restic/valheim".path;

    basePath = "/var/lib/valheim/.config/unity3d/IronGate/Valheim/worlds_local";
    paths = [
      "Test12.db"
      "Test12.fwl"
    ];

    timerConfig.OnCalendar = "*:0/15";
  };
}
