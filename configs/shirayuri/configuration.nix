{
  inputs',
  pkgs,
  username,
  ...
}:

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
      inputs'.deploy-rs.packages.deploy-rs
    ];

  programs.droidcam.enable = true;

  hm.news.display = "show";
  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
