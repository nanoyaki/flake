{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.modules.vr;
in

{
  options.modules.vr.enableAmdgpuPatch = mkEnableOption "kernel module patch for high priority graphics";

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

    hm.xdg.configFile = {
      "openxr/1/active_runtime.json".text = ''
        {
          "file_format_version": "1.0.0",
          "runtime": {
            "name": "Monado",
            "library_path": "${pkgs.monado}/lib/libopenxr_monado.so"
          }
        }
      '';

      "openvr/openvrpaths.vrpath".text = ''
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

    modules.amdgpu.patches = mkIf cfg.enableAmdgpuPatch [
      (pkgs.fetchpatch {
        name = "cap_sys_nice_begone.patch";
        url = "https://raw.githubusercontent.com/Scrumplex/pkgs/d2c85f8c6eb944acbfaea133fc95ee8fe7825ee0/kernelPatches/cap_sys_nice_begone.patch";
        hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
      })
    ];

    programs.steam.extraCompatPackages = mkIf config.programs.steam.enable [
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

    # modules.audio.latency = lib.mkForce 2048;

    # Not recommended as of yet
    # https://lvra.gitlab.io/docs/distros/nixos/#envision
    # programs.envision.enable = true;

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
      SURVIVE_GLOBALSCENESOLVER = "0";
    };

    environment.sessionVariables.LIBMONADO_PATH = "${config.services.monado.package}/lib/libopenxr_monado.so";

    environment.systemPackages = with pkgs; [
      index_camera_passthrough
      wlx-overlay-s
      # lighthouse-steamvr
    ];
  };
}
