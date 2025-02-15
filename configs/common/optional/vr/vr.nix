{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.nixpkgs-xr.nixosModules.nixpkgs-xr
  ];

  nixpkgs.xr.enable = true;

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
    (pkgs.proton-ge-rtsp-bin.overrideAttrs rec {
      version = "GE-Proton9-22-rtsp17-1";
      src = pkgs.fetchzip {
        url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${version}/${version}.tar.gz";
        hash = "sha256-GeExWNW0J3Nfq5rcBGiG2BNEmBg0s6bavF68QqJfuX8=";
      };
    })
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
  };

  environment.systemPackages = with pkgs; [
    # index_camera_passthrough
    wlx-overlay-s
    wayvr-dashboard

    lighthouse-steamvr

    openal
  ];
}
