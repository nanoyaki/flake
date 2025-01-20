{
  lib,
  inputs',
  pkgs,
  username,
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
  sec."deployment/private".owner = username;

  modules.audio.latency = 32;

  environment.systemPackages =
    (with pkgs; [
      protonvpn-gui
      imagemagick

      winetricks
      wineWowPackages.stableFull

      ffmpeg-full
    ])
    ++ [
      tcVid
      tcVidAac
      inputs'.deploy-rs.packages.deploy-rs
    ];

  programs.droidcam.enable = true;

  hm.news.display = "show";
  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
