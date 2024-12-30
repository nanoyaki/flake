{
  lib,
  pkgs,
  packages,
  config,
  ...
}:

# https://wiki.nixos.org/wiki/VR#Monado
{
  nixpkgs.overlays = [
    (self: super: {
      monado = super.monado.overrideAttrs (oldAttrs: {
        cmakeFlags = [
          (lib.cmakeBool "XRT_FEATURE_SERVICE" true)
          (lib.cmakeBool "XRT_OPENXR_INSTALL_ABSOLUTE_RUNTIME_PATH" true)
          (lib.cmakeBool "XRT_HAVE_STEAM" true)
          (lib.cmakeBool "CMAKE_EXPORT_COMPILE_COMMANDS" true)
          (lib.cmakeBool "XRT_HAVE_SYSTEM_CJSON" true)
        ];
      });
    })
  ];

  hm.xdg.configFile."openxr/1/active_runtime.json".source =
    "${pkgs.monado}/share/openxr/1/openxr_monado.json";

  hm.home.file."${config.hm.xdg.dataHome}/monado/hand-tracking-models".source = pkgs.fetchgit {
    url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models.git";
    fetchLFS = true;
    hash = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
  };

  # Make sure to `sudo renice -20 -p $(pgrep monado)`
  services.monado = {
    enable = true;
    defaultRuntime = true;
    highPriority = true;
    package = pkgs.monado;
  };

  systemd.user.services.monado = {
    serviceConfig = {
      ExecStartPost = "${lib.getExe packages.lighthouse} -s ON";
      ExecStopPost = "${lib.getExe packages.lighthouse} -s OFF";
    };

    environment = {
      STEAMVR_PATH = "${config.hm.xdg.dataHome}/Steam/steamapps/common/SteamVR";
      XR_RUNTIME_JSON = "${config.hm.xdg.configHome}/openxr/1/active_runtime.json";
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
      WMR_HANDTRACKING = "1";
      XRT_COMPOSITOR_SCALE_PERCENTAGE = "140";
      SURVIVE_GLOBALSCENESOLVER = "0";
      SURVIVE_TIMECODE_OFFSET_MS = "-6.94";
    };
  };

  systemd.user.services.wlx-overlay-s = {
    environment.LIBMONADO_PATH = "${config.services.monado.package}/lib/libmonado.so";

    after = [ "monado.service" ];
    bindsTo = [ "monado.service" ];
    wantedBy = [ "monado.service" ];
    requires = [
      "monado.socket"
      "graphical-session.target"
    ];
  };
}
