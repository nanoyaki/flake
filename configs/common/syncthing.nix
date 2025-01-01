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
    "syncthing/cert".owner = cfg.user;
    "syncthing/key".owner = cfg.user;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    cert = config.sec."syncthing/cert".path;
    key = config.sec."syncthing/key".path;

    settings = {
      devices."thelessone".id = "4MLMRMK-3Y4OSRK-BVJHBRW-NRGIYRC-HOHOOOB-KJKUUTO-X7LGP4M-3LNTOQE";

      folders."Shared" = {
        path = "/home/shared";
        devices = builtins.attrNames cfg.settings.devices;
        label = "Shared Directory";
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
  systemd.tmpfiles.settings."10-syncthing-shared"."/home/shared".d = dirCfg;
}
