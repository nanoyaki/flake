{
  lib,
  pkgs,
  config,
  ...
}:

let
  monadoEnabled = config.services.monado.enable;
in

{
  systemd.user.services.wayvr = {
    description = "WayVR background service";
    wantedBy = lib.mkIf monadoEnabled [ "monado.service" ];
    after = lib.mkIf monadoEnabled [ "monado.service" ];
    bindsTo = lib.mkIf monadoEnabled [ "monado.service" ];
    partOf = lib.mkIf monadoEnabled [ "monado.service" ];

    unitConfig.ConditionUser = "!root";

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.wayvr} --openxr";
      Restart = "on-failure";
      Type = "simple";
    };

    environment = {
      XR_RUNTIME_JSON = "${config.hm.xdg.configHome}/openxr/1/active_runtime.json";
      LIBMONADO_PATH = lib.mkIf monadoEnabled "${config.services.monado.package}/lib/libmonado.so";
    };

    restartTriggers = [ pkgs.wayvr ];
  };

  environment.systemPackages = [ pkgs.wayvr ];
}
