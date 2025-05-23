{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkIf
    ;

  cfg = config.nanoflake.mpv;

  defaultApplications = {
    "audio/*" = mkIf cfg.defaultAudioPlayer "mpv.desktop";
    "video/*" = mkIf cfg.defaultVideoPlayer "mpv.desktop";
  };
in

{
  options.nanoflake.mpv = {
    defaultAudioPlayer = mkOption {
      type = types.bool;
      default = true;
    };

    defaultVideoPlayer = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    hm.programs.mpv = {
      enable = true;

      config = {
        osc = "no";
        volume = 20;
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

    xdg.mime = { inherit defaultApplications; };
    hm.xdg.mimeApps = { inherit defaultApplications; };
  };
}
