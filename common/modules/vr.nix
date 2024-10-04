{
  lib,
  pkgs,
  config,
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

    enableKernelPatch = mkEnableOption "kernel patch for high priority graphics";
  };

  config = mkIf cfg.enable {
    boot.kernelPatches = mkIf cfg.enableKernelPatch [
      {
        name = "cap_sys_nice_begone";
        patch = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/Scrumplex/pkgs/d2c85f8c6eb944acbfaea133fc95ee8fe7825ee0/kernelPatches/cap_sys_nice_begone.patch";
          hash = lib.fakeHash;
        };
      }
    ];

    programs.steam.extraCompatPackages = mkIf config.programs.steam.enable [
      (pkgs.proton-ge-bin.overrideAttrs (
        finalAttrs: _: {
          version = "GE-Proton9-11-rtsp15";
          src = pkgs.fetchzip {
            url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
            hash = "sha256-aHKOKhaOs1v+LwJdtQMDblcd5Oee9GzLC8SLYPA9jQQ=";
          };
        }
      ))
    ];

    programs.envision.enable = true;

    services.monado = {
      enable = true;
      defaultRuntime = false;
    };

    environment.systemPackages = with pkgs; [
      index_camera_passthrough
      opencomposite-helper
      wlx-overlay-s
      lighthouse-steamvr
    ];
  };
}
