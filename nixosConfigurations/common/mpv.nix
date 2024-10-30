{
  lib,
  config,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkIf
    mkMerge
    ;

  cfg = config.modules.mpv;
in

{
  options.modules.mpv = {
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
    hm.programs.mpv.enable = true;

    xdg.mime.defaultApplications = mkMerge [
      (mkIf cfg.defaultAudioPlayer {
        "audio/aac" = "mpv.desktop";
        "audio/ac3" = "mpv.desktop";
        "audio/AMR" = "mpv.desktop";
        "audio/AMR-WB" = "mpv.desktop";
        "audio/ape" = "mpv.desktop";
        "audio/basic" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/midi" = "mpv.desktop";
        "audio/mp4" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/opus" = "mpv.desktop";
        "audio/vnd.dts" = "mpv.desktop";
        "audio/vnd.dts.hd" = "mpv.desktop";
        "audio/x-aiff" = "mpv.desktop";
        "audio/x-ape" = "mpv.desktop";
        "audio/x-flac" = "mpv.desktop";
        "audio/x-matroska" = "mpv.desktop";
        "audio/x-mpegurl" = "mpv.desktop";
        "audio/x-ms-wma" = "mpv.desktop";
        "audio/x-musepack" = "mpv.desktop";
        "audio/x-pn-realaudio" = "mpv.desktop";
        "audio/x-scpls" = "mpv.desktop";
        "audio/x-speex" = "mpv.desktop";
        "audio/x-tta" = "mpv.desktop";
        "audio/x-wav" = "mpv.desktop";
        "audio/x-wavpack" = "mpv.desktop";
        "audio/x-xm" = "mpv.desktop";
      })
      (mkIf cfg.defaultVideoPlayer {
        "video/3gpp" = "mpv.desktop";
        "video/3gpp2" = "mpv.desktop";
        "video/annodex" = "mpv.desktop";
        "video/avi" = "mpv.desktop";
        "video/divx" = "mpv.desktop";
        "video/flv" = "mpv.desktop";
        "video/h264" = "mpv.desktop";
        "video/mp2t" = "mpv.desktop";
        "video/mp4" = "mpv.desktop";
        "video/mpeg" = "mpv.desktop";
        "video/mpeg2" = "mpv.desktop";
        "video/msvideo" = "mpv.desktop";
        "video/ogg" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "video/vnd.mpegurl" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-flv" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/x-mng" = "mpv.desktop";
        "video/x-ms-asf" = "mpv.desktop";
        "video/x-ms-wmv" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
        "video/x-nsv" = "mpv.desktop";
        "video/x-ogm+ogg" = "mpv.desktop";
      })
    ];
  };
}
