{
  lib,
  pkgs,
  config,
  ...
}:

let
  tcVid = pkgs.writeShellScriptBin "tcVid" ''
    ${lib.getExe pkgs.ffmpeg-full} -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 -i "$1" -c:v av1_vaapi -b:v 3000k -maxrate 4000k "$1_AV1".mp4
  '';
  tcVidAac = pkgs.writeShellScriptBin "tcVidAac" ''
    ${lib.getExe pkgs.ffmpeg-full} -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 -i "$1" -c:v av1_vaapi -b:v 3000k -maxrate 4000k -c:a aac -profile:a aac_main -b:a 320k -ac 2 -dn "$1_AV1".mp4
  '';
in

{
  hm.sec."deployment/private".path = "${config.hm.home.homeDirectory}/.ssh/deployment";

  nanoflake = {
    localization = {
      language = [
        "en_GB"
        "de_DE"
        "ja_JP"
      ];
      extraLocales = [ "ja_JP.UTF-8/UTF-8" ];
    };
    audio.latency = 256;

    firefox.enablePolicies = true;
  };

  environment.systemPackages =
    (with pkgs; [
      protonvpn-gui
      imagemagick

      winetricks
      wineWowPackages.stableFull

      ffmpeg-full
      yt-dlp
      obs-studio

      meow
      gimp
      smile
    ])
    ++ [
      tcVid
      tcVidAac
    ];

  programs.kde-pim.merkuro = true;

  hm.news.display = "show";
  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
