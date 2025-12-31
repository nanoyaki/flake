{ lib, config, ... }:

let
  cfg = config.services.syncthing;

  devices = {
    himeyuri.id = "AMNOX7D-5A7KHW6-4LGCATR-2CWDZEO-W4DEZEY-VX65U5L-UQNZTTT-IRPPGQU";
    kuroyuri.id = "";
    pixel-7.id = "YMHV7NP-MHGM7OS-6KPGSG5-GXKUFOV-DXNGEHK-PPGK4WH-ZZ3AKZ4-TRJ3AA3";
  };

  deviceNames = builtins.attrNames devices;
in

{
  options.services.syncthing'.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf config.services.syncthing'.enable {
    users.users.syncthing.homeMode = "750";
    users.users.${config.nanoSystem.mainUserName or "hana"}.extraGroups = [ cfg.group ];
    systemd.tmpfiles.settings.syncthing."${cfg.dataDir}/sync".d = {
      mode = "770";
      inherit (cfg) user group;
    };

    services.syncthing = {
      enable = true;
      settings = {
        inherit devices;
        folders.sync = {
          path = "~/sync";
          devices = deviceNames;
          ignorePerms = true;
          copyOwnershipFromParent = true;
        };
        options.relaysEnabled = true;
      };
    };
  };
}
