{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.nano.vr;
in {
  options.services.nano.vr = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom VR options.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # VR
      pavucontrol
      index_camera_passthrough
      opencomposite-helper
      wlx-overlay-s
      lighthouse-steamvr
    ];

    # VR Patch
    boot.kernelPatches = [
      {
        name = "cap_sys_nice_begone";
        patch = builtins.fetchurl {
          url = "https://codeberg.org/Scrumplex/flake/raw/commit/3ec4940bb61812d3f9b4341646e8042f83ae1350/pkgs/cap_sys_nice_begone.patch";
          sha256 = "07a1e8cb6f9bcf68da3a2654c41911d29bcef98d03fb6da25f92595007594679";
        };
      }
    ];

    programs.steam.extraCompatPackages = [
      (pkgs.proton-ge-bin.overrideAttrs (finalAttrs: _: {
        version = "GE-Proton9-10-rtsp12";
        src = pkgs.fetchzip {
          url = "https://github.com/SpookySkeletons/proton-ge-rtsp/releases/download/${finalAttrs.version}/${finalAttrs.version}.tar.gz";
          hash = "sha256-aHKOKhaOs1v+LwJdtQMDblcd5Oee9GzLC8SLYPA9jQQ=";
        };
      }))
    ];

    # VR Compositor and Envision
    programs.envision.enable = true;
    services.monado = {
      enable = true;
      defaultRuntime = false;
    };
  };
}
