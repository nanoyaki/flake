{
  lib,
  pkgs,
  packages,
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
  ];

  hm.home.file.".alsoftrc".text = ''
    hrtf = true
  '';

  hm.xdg.configFile."openvr/openvrpaths.vrpath".text = ''
    {
      "config" :
      [
        "${config.hm.xdg.dataHome}/Steam/config"
      ],
      "external_drivers" : null,
      "jsonid" : "vrpathreg",
      "log" :
      [
        "${config.hm.xdg.dataHome}/Steam/logs"
      ],
      "runtime" :
      [
        "${pkgs.opencomposite}/lib/opencomposite"
      ],
      "version" : 1
    }
  '';

  programs.steam.extraCompatPackages = [
    pkgs.proton-ge-rtsp-bin
  ];

  systemd.user.services.wlx-overlay-s = {
    description = "wlx-overlay-s service";

    unitConfig.ConditionUser = "!root";

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.wlx-overlay-s} --openxr";
      Restart = "on-failure";
      Type = "simple";
    };

    environment = {
      OXR_VIEWPORT_SCALE_PERCENTAGE = "120";
      XR_RUNTIME_JSON = "${config.hm.xdg.configHome}/openxr/1/active_runtime.json";
    };

    restartTriggers = [ pkgs.wlx-overlay-s ];

    after = [ "monado.service" ];
    bindsTo = [ "monado.service" ];
    wantedBy = [ "monado.service" ];
    requires = [
      "monado.socket"
      "graphical-session.target"
    ];
  };

  environment.systemPackages = [
    pkgs.index_camera_passthrough
    pkgs.wlx-overlay-s

    packages.lighthouse

    pkgs.openal
  ];
}
