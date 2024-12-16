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
    "syncthing/thelessone/cert".owner = cfg.user;
    "syncthing/thelessone/key".owner = cfg.user;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    cert = config.sec."syncthing/thelessone/cert".path;
    key = config.sec."syncthing/thelessone/key".path;

    settings = {
      devices = {
        "shirayuri".id = "QA4VLNU-UT72TUA-GWE5QQX-5G23QHN-P3XFLAX-3IA2H6S-UEK22S3-OMXFJA5";
        "kuroyuri".id = "FYR4D2E-6FSJNJR-5U43Q75-YUYCY5V-HZUIVDA-V74MXRY-DRJHBMZ-73OO7AO";
      };

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
