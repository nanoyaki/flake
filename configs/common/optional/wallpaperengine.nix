{ config, ... }:

{
  hm.services.linux-wallpaperengine = {
    enable = true;
    clamping = "clamp";
    assetsPath = "${config.hm.xdg.dataHome}/Steam/steamapps/common/wallpaper_engine/assets";
    wallpapers = [
      # ls /sys/class/drm
      {
        # Made in Abyss - Fishing Nanachi
        monitor = "DP-1";
        wallpaperId = "1160536647";
        fps = 144;
        audio.silent = true;
      }
      {
        # Made in Abyss - Fishing Nanachi
        monitor = "HDMI-A-1";
        wallpaperId = "1160536647";
        fps = 144;
        audio.silent = true;
      }
    ];
  };
}
