{
  lib,
  inputs',
  pkgs,
  username,
  ...
}:

let
  tcVid = pkgs.writeShellScriptBin "tcVid" ''
    ${lib.getExe pkgs.ffmpeg-full} -i "$1" -c:v h264 -pix_fmt yuv420p -profile:v high422 -movflags +faststart -c:a aac -profile:a aac_main -b:a 320k -ac 2 -dn "$1".mp4
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
      inputs'.deploy-rs.packages.deploy-rs
    ];

  programs.droidcam.enable = true;

  hm.news.display = "show";
  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
