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

  programs.steam.extraCompatPackages = [
    pkgs.proton-ge-rtsp-bin
  ];

  systemd.user.services.wlx-overlay-s = {
    description = "wlx-overlay-s service";

    unitConfig.ConditionUser = "!root";

    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5s";
      ExecStart = lib.getExe pkgs.wlx-overlay-s;
      Restart = "no";
      Type = "simple";
    };

    restartTriggers = [ pkgs.wlx-overlay-s ];

    after = [ "monado.service" ];
    partOf = [ "monado.service" ];
    wantedBy = [ "monado.service" ];
  };

  environment.sessionVariables.XR_RUNTIME_JSON = "${config.hm.xdg.configHome}/openxr/1/active_runtime.json";

  environment.systemPackages = [
    pkgs.index_camera_passthrough
    pkgs.wlx-overlay-s

    packages.lighthouse

    pkgs.openal
  ];
}
