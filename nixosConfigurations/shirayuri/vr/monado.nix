{ pkgs, config, ... }:

# https://wiki.nixos.org/wiki/VR#Monado
{
  hm.xdg.configFile = {
    "steamargs/vrchat" = {
      force = true;
      text = ''env PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%'';
    };

    "openxr/1/active_runtime.json".text = ''
      {
        "file_format_version": "1.0.0",
        "runtime": {
          "name": "Monado",
          "library_path": "${pkgs.monado}/lib/libopenxr_monado.so"
        }
      }
    '';

    "openvr/openvrpaths.vrpath.opencomp" = {
      force = true;
      text = ''
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
    };

    "openvr/openvrpaths.vrpath".source = config.hm.lib.file.mkOutOfStoreSymlink "${config.hm.xdg.configHome}/openvr/openvrpaths.vrpath.opencomp";
  };

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

  systemd.user.services.monado.environment = {
    STEAMVR_LH_ENABLE = "1";
    XRT_COMPOSITOR_COMPUTE = "1";
    WMR_HANDTRACKING = "0";
    XRT_COMPOSITOR_SCALE_PERCENTAGE = "140";
    SURVIVE_GLOBALSCENESOLVER = "0";
    SURVIVE_TIMECODE_OFFSET_MS = "-6.94";
  };

  environment.sessionVariables.LIBMONADO_PATH = "${config.services.monado.package}/lib/libmonado.so";
}
