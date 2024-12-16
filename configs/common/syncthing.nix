{ config, ... }:

let
  cfg = config.services.syncthing;
  dirCfg = {
    user = config.hm.home.username;
    group = "users";
    mode = "0777";
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
      devices."thelessone".id = "4MLMRMK-3Y4OSRK-BVJHBRW-NRGIYRC-HOHOOOB-KJKUUTO-X7LGP4M-3LNTOQE";

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
