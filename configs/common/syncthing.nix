{ config, ... }:

let
  cfg = config.services.syncthing;
  dirCfg = {
    inherit (cfg) user groups;
    mode = "0700";
  };
in

{
  sec = {
    "syncthing/${config.networking.hostName}/cert".owner = cfg.user;
    "syncthing/${config.networking.hostName}/key".owner = cfg.user;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    cert = config.sec."syncthing/${config.networking.hostName}/cert".path;
    key = config.sec."syncthing/${config.networking.hostName}/key".path;

    settings = {
      devices."thelessone".id = "YEOMDVN-YO4L6A7-RDT7BYL-6ZKOM7L-G2Q6PZU-EHYJNGZ-USQDY25-7V6SLAO";

      folders."Shared" = {
        path = "/var/lib/syncthing/shared";
        devices = builtins.attrNames cfg.settings.devices;
        label = "Shared Directory";
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  systemd.tmpfiles.settings."10-syncthing-shared"."/var/lib/syncthing/shared".d = dirCfg;
}
