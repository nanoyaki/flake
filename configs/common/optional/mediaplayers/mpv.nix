{
  lib,
  lib',
  pkgs,
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
  inherit (lib') mapDefaultForMimeTypes;

  cfg = config.nanoflake.mpv;

  mpv = pkgs.mpv.overrideAttrs { name = "mpv"; };

  defaultAudioApp = mapDefaultForMimeTypes mpv [
    "audio/aac"
    "audio/ac3"
    "audio/AMR"
    "audio/AMR-WB"
    "audio/ape"
    "audio/basic"
    "audio/flac"
    "audio/midi"
    "audio/mp4"
    "audio/mpeg"
    "audio/ogg"
    "audio/opus"
    "audio/vnd.dts"
    "audio/vnd.dts.hd"
    "audio/x-aiff"
    "audio/x-ape"
    "audio/x-flac"
    "audio/x-matroska"
    "audio/x-mpegurl"
    "audio/x-ms-wma"
    "audio/x-musepack"
    "audio/x-pn-realaudio"
    "audio/x-scpls"
    "audio/x-speex"
    "audio/x-tta"
    "audio/x-wav"
    "audio/x-wavpack"
    "audio/x-xm"
  ];

  defaultVideoApp = mapDefaultForMimeTypes mpv [
    "video/3gpp"
    "video/3gpp2"
    "video/annodex"
    "video/avi"
    "video/divx"
    "video/flv"
    "video/h264"
    "video/mp2t"
    "video/mp4"
    "video/mpeg"
    "video/mpeg2"
    "video/msvideo"
    "video/ogg"
    "video/quicktime"
    "video/x-flv"
    "video/x-matroska"
    "video/x-mng"
    "video/x-ms-asf"
    "video/x-ms-wmv"
    "video/x-msvideo"
    "video/x-nsv"
    "video/vnd.mpegurl"
    "video/webm"
    "video/x-ogm+ogg"
  ];
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

    xdg.mime.defaultApplications = mkMerge [
      (mkIf cfg.defaultAudioPlayer defaultAudioApp)
      (mkIf cfg.defaultVideoPlayer defaultVideoApp)
    ];

    hm.xdg.mimeApps.defaultApplications = mkMerge [
      (mkIf cfg.defaultAudioPlayer defaultAudioApp)
      (mkIf cfg.defaultVideoPlayer defaultVideoApp)
    ];
  };
}
