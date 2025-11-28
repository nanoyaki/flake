{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib'.options) mkTrueOption mkFalseOption;
  inherit (lib) mkIf;

  cfg = config.config'.mpv;

  defaultApplications = {
    "audio/*" = mkIf cfg.defaultAudioPlayer "mpv.desktop";
    "video/*" = mkIf cfg.defaultVideoPlayer "mpv.desktop";
  };
in

{
  options.config'.mpv = {
    enable = mkFalseOption;

    defaultAudioPlayer = mkTrueOption;
    defaultVideoPlayer = mkTrueOption;
  };

  config = mkIf cfg.enable {
    xdg.mime = { inherit defaultApplications; };
    hms = [
      {
        xdg.mimeApps = { inherit defaultApplications; };
        programs.mpv = {
          enable = true;

          config = {
            osc = "no";
            volume = 40;
          };

          scripts = with pkgs.mpvScripts; [
            sponsorblock
            thumbfast
            modernx
            mpvacious
            mpv-discord
            mpv-subtitle-lines
            mpv-playlistmanager
            mpv-cheatsheet
          ];
        };
      }
    ];
  };
}
