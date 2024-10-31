{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [ inputs.nixpkgs-xr.overlays.default ];

  nix.settings = {
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
  };

  hm.home.file.".alsoftrc".text = ''
    hrtf = true
  '';

  programs.steam.extraCompatPackages = [
    (pkgs.proton-ge-bin.overrideAttrs (
      finalAttrs: _: {
        version = "GE-Proton9-11-rtsp15";
        src = pkgs.fetchzip {
          url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
          hash = "sha256-3QWJUVkMgZldEXFVsry1FoKVE9y6Tg4IREAruPuL+hk=";
        };
      }
    ))
  ];

  systemd.user.services.wlx-overlay-s =
    {
      description = "wlx-overlay-s service";

      unitConfig.ConditionUser = "!root";

      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10s";
        ExecStart = lib.getExe pkgs.wlx-overlay-s;
        Restart = "no";
        Type = "simple";
      };

      restartTriggers = [ pkgs.wlx-overlay-s ];
    }
    // (lib.mkIf config.services.monado.enable {
      requires = [ "monado.service" ];
      after = [ "monado.service" ];
      bindsTo = [ "monado.service" ];
    });

  environment.sessionVariables.XR_RUNTIME_JSON = "${config.hm.xdg.configHome}/openxr/1/active_runtime.json";

  environment.systemPackages = with pkgs; [
    index_camera_passthrough
    wlx-overlay-s

    openal
  ];
}
