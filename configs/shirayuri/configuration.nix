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
    ])
    ++ [
      inputs'.deploy-rs.packages.deploy-rs
    ];

  programs.droidcam.enable = true;

  services.transmission = {
    enable = false;
    webHome = pkgs.flood-for-transmission;
    settings.download-dir = "/mnt/os-shared/Torrents";
  };

  hm.news.display = "show";

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
