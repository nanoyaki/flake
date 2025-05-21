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
  hm.sec = {
    "deploymentThelessone/private".path = "${config.hm.home.homeDirectory}/.ssh/deploymentThelessone";
    "deploymentYuri/private".path = "${config.hm.home.homeDirectory}/.ssh/deploymentYuri";
  };

  networking.networkmanager.enable = true;

  nanoflake = {
    localization = {
      language = [
        "en_GB"
        "de_DE"
        "ja_JP"
      ];
      extraLocales = [ "ja_JP.UTF-8/UTF-8" ];
    };
    audio.latency = lib.mkDefault 256;

    firefox.enablePolicies = true;
  };

  specialisation.osu.configuration.nanoflake.audio.latency = 32;

  environment.systemPackages =
    (with pkgs; [
      # protonvpn-gui
      imagemagick

      winetricks
      wineWowPackages.stableFull

      ffmpeg-full
      yt-dlp
      obs-studio

      meow
      pyon
      gimp
      smile
      jq
    ])
    ++ [
      tcVid
      tcVidAac
    ];

  programs.kde-pim.merkuro = true;

  virtualisation.waydroid.enable = true;

  hm.news.display = "show";
  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
  hm.home.file.".face.icon".source = pkgs.fetchurl {
    url = "https://cdn.bsky.app/img/avatar/plain/did:plc:majihettvb7ieflgmkvujecu/bafkreib6be5oip6rht4vqnmldx5hzulr6irh55yarwbmxt2us2imfoiyd4@png";
    hash = "sha256-mQ8il+zU30EAxFAulUFkkXvYs9gubKCeQtaYRyJNXJ8=";
  };
}
