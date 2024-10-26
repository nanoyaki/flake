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
in

{
  options.modules.vr = {
    enableAmdgpuPatch = mkEnableOption "kernel module patch for high priority graphics";

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
        text = ''QT_QPA_PLATFORMTHEME=kde __GL_MaxFramesAllowed=0 SDL_DYNAMIC_API=${pkgs.SDL2}/lib/libSDL2.so SDL_VIDEODRIVER=wayland %command%'';
      };

      "steamargs/vrchat" = {
        enable = isMonado;
        text = ''env LC_ALL=en_US.UTF-8 PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc %command%'';
      };

      "openxr/1/active_runtime.json" = {
        enable = isMonado;
        text = ''
          {
            "file_format_version": "1.0.0",
            "runtime": {
              "name": "Monado",
              "library_path": "${pkgs.monado}/lib/libmonado.so"
            }
          }
        '';
      };

      # https://steamcommunity.com/app/250820/discussions/5/4757578278663049910/
      "openvr/openvrpaths.vrpath" = {
        enable = isMonado;
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
    };

    modules.amdgpu.patches = mkIf cfg.enableAmdgpuPatch [
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

    modules.audio.latency = lib.mkForce 2048;

    # Make sure to `sudo renice -20 -p $(pgrep monado)`
    services.monado = mkIf isMonado {
      enable = true;
      defaultRuntime = true;
      highPriority = true;
      package = pkgs.monado;
    };

    systemd.user.services.monado.environment = mkIf isMonado {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
      WMR_HANDTRACKING = "0";
    };

    environment.sessionVariables.LIBMONADO_PATH = mkIf isMonado "${config.services.monado.package}/lib/libmonado.so";

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
