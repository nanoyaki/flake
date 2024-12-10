{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.steamvr;
in

{
  options.modules.steamvr.enableAmdgpuPatch = mkEnableOption "kernel module patch for high priority graphics for steamvr";

  imports = [
    ./amdgpu.nix
  ];

  config = {
    # Make sure `enableLinuxVulkanAsync = true`
    # is set for asynchronous reprojection in
    # `.steam/steam/config/steamvr.vrsettings`
    # as that file is mutable
    hm.xdg.configFile."steamargs/steamvr" = {
      force = true;
      text = ''QT_QPA_PLATFORMTHEME=kde __GL_MaxFramesAllowed=0 SDL_DYNAMIC_API=${pkgs.SDL2}/lib/libSDL2.so SDL_VIDEODRIVER=wayland %command%'';
    };

    hardware.amdgpu.patches = mkIf cfg.enableAmdgpuPatch [
      (pkgs.fetchpatch {
        name = "cap_sys_nice_begone.patch";
        url = "https://raw.githubusercontent.com/Scrumplex/pkgs/d2c85f8c6eb944acbfaea133fc95ee8fe7825ee0/kernelPatches/cap_sys_nice_begone.patch";
        hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
      })
    ];
  };
}
