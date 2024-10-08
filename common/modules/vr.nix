{
  lib,
  pkgs,
  config,
  username,
  ...
}:

let
  cfg = config.modules.vr;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;
in

{
  options.modules.vr = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom VR options.";
    };

    enableAmdgpuPatch = mkEnableOption "kernel patch for high priority graphics";
  };

  # https://wiki.nixos.org/wiki/VR#Monado
  config = mkIf cfg.enable {
    home-manager.users.${username}.imports = [
      ./home/vr.nix
    ];

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

    modules.audio.latency = lib.mkForce 2048;

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
      # index_camera_passthrough
      motoc
      wlx-overlay-s
      lighthouse-steamvr
      # opencomposite # -vendored
      # opencomposite-hand-fixes
    ];
  };
}
