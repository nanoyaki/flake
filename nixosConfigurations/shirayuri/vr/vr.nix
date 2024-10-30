{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    ;

  cfg = config.modules.vr;

  isMonado = cfg.enable == "monado";
  isSteamvr = cfg.enable == "steamvr";
  isEnvision = cfg.enable == "envision";

  monado = pkgs.monado.overrideAttrs {
    pname = "monado";
    version = "9afaca98cdbeead836988c0c4be87533795287fc";
    src = pkgs.fetchgit {
      url = "https://gitlab.freedesktop.org/monado/monado.git";
      rev = "9afaca98cdbeead836988c0c4be87533795287fc";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-FP6bHI67AzcR1YftPHheL2fp80HjBOjc2xGq/VrMpb4=";
    };
  };

  opencomposite = pkgs.opencomposite.overrideAttrs {
    pname = "opencomposite";
    version = "e162c7e9be2521a357fba4bee13af85437a1027b";
    src = pkgs.fetchgit {
      url = "https://gitlab.com/znixian/OpenOVR.git";
      rev = "e162c7e9be2521a357fba4bee13af85437a1027b";
      fetchSubmodules = true;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-+suq0gV8zRDhF3ApnzQCC/5st59VniU6v7TcDdght6Q=";
    };
  };
in

{
  options.modules.vr = {
    enableAmdgpuPatch = mkEnableOption "kernel module patch for high priority graphics for steamvr";

    enableMonado = mkEnableOption "the use of monado rather than steamvr";

    enable = mkOption {
      type = types.enum [
        "steamvr"
        "monado"
        "envision"
      ];
      default = "monado";
    };
  };

  imports = [
    ./amdgpu.nix
  ];

  # https://wiki.nixos.org/wiki/VR#Monado
  config = {
    nixpkgs.overlays = [ inputs.nixpkgs-xr.overlays.default ];

    nix.settings = {
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };

    hm.home.file."${config.hm.xdg.dataHome}/monado/hand-tracking-models" = {
      enable = isMonado;
      source = pkgs.fetchgit {
        url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models.git";
        fetchLFS = true;
        hash = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
      };
    };

    hm.home.file.".alsoftrc".text = ''
      hrtf = true
    '';

    hm.xdg.configFile = {
      # Make sure `enableLinuxVulkanAsync = true`
      # is set for asynchronous reprojection in
      # .steam/steam/config/steamvr.vrsettings as
      # that file is mutable
      "steamargs/steamvr" = {
        enable = isSteamvr;
        force = true;
        text = ''QT_QPA_PLATFORMTHEME=kde __GL_MaxFramesAllowed=0 SDL_DYNAMIC_API=${pkgs.SDL2}/lib/libSDL2.so SDL_VIDEODRIVER=wayland %command%'';
      };

      "steamargs/vrchat" = {
        enable = isMonado;
        force = true;
        text = ''env LC_ALL=en_US.UTF-8 PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%'';
      };

      "openxr/1/active_runtime.json" = {
        enable = isMonado;
        force = true;
        text = ''
          {
            "file_format_version": "1.0.0",
            "runtime": {
              "name": "Monado",
              "library_path": "${pkgs.monado}/lib/libopenxr_monado.so"
            }
          }
        '';
      };

      # https://steamcommunity.com/app/250820/discussions/5/4757578278663049910/
      "openvr/openvrpaths.vrpath.opencomp" = {
        enable = isMonado;
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
              "${opencomposite}/lib/opencomposite"
            ],
            "version" : 1
          }
        '';
      };

      "openvr/openvrpaths.vrpath" = {
        source = config.hm.lib.file.mkOutOfStoreSymlink "${config.hm.xdg.configHome}/openvr/openvrpaths.vrpath.opencomp";
        force = true;
      };
    };

    hardware.amdgpu.patches = mkIf (cfg.enableAmdgpuPatch && isSteamvr) [
      (pkgs.fetchpatch {
        name = "cap_sys_nice_begone.patch";
        url = "https://raw.githubusercontent.com/Scrumplex/pkgs/d2c85f8c6eb944acbfaea133fc95ee8fe7825ee0/kernelPatches/cap_sys_nice_begone.patch";
        hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
      })
    ];

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

    # Make sure to `sudo renice -20 -p $(pgrep monado)`
    services.monado = mkIf isMonado {
      enable = true;
      defaultRuntime = true;
      highPriority = true;
      package = monado;
    };

    systemd.user.services.monado.environment = mkIf isMonado {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
      WMR_HANDTRACKING = "0";
      XRT_COMPOSITOR_SCALE_PERCENTAGE = "140";
      SURVIVE_GLOBALSCENESOLVER = "0";
      SURVIVE_TIMECODE_OFFSET_MS = "-6.94";
    };

    systemd.user.services.wlx-overlay-s = mkIf (isMonado || isSteamvr) {
      description = "wlx-overlay-s service";

      requires = [ "monado.service" ];
      after = [ "monado.service" ];
      bindsTo = [ "monado.service" ];

      unitConfig.ConditionUser = "!root";

      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10s";
        ExecStart = lib.getExe pkgs.wlx-overlay-s;
        Restart = "no";
        Type = "simple";
      };

      restartTriggers = [ pkgs.wlx-overlay-s ];
    };

    environment.sessionVariables = mkIf isMonado {
      XR_RUNTIME_JSON = "${config.hm.xdg.configHome}/openxr/1/active_runtime.json";
      LIBMONADO_PATH = "${config.services.monado.package}/lib/libmonado.so";
    };

    # Not recommended as of yet
    # https://lvra.gitlab.io/docs/distros/nixos/#envision
    programs.envision.enable = isEnvision;

    environment.systemPackages = with pkgs; [
      index_camera_passthrough
      wlx-overlay-s

      openal
    ];
  };
}
