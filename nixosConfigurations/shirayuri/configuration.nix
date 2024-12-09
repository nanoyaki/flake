{
  inputs',
  pkgs,
  ...
}:

{
  modules.audio.latency = 32;
  modules.chrome.extensions = [
    "languageTool"
    "bitwarden"
    "linkToTextFragment"
    "steamDb"
    "violentmonkey"
    "ublockOrigin"
    "googleDocsOffline"
    "darkReader"
    "keepaAmazonPriceTracker"

    "catppuccinMocha"
    "stylus"

    "jishoOjad"
    "jisho-pitcher"
    "jishoOnTheFly"
    "searchJisho"
    "migaku"

    "betterTtv"
    "returnYoutubeDislike"
    "sponsorBlock"
    "automaticTwitch"
    "skyFollowerBridge"
  ];

  environment.systemPackages =
    (with pkgs; [
      protonvpn-gui
      imagemagick
    ])
    ++ [
      inputs'.deploy-rs.packages.deploy-rs
    ];

  programs.droidcam.enable = true;

  services.transmission = {
    enable = false;
    webHome = pkgs.flood-for-transmission;
    settings.download-dir = "/mnt/1TB-SSD/Torrents";
  };

  system.stateVersion = "24.11";
  hm.home.stateVersion = "24.11";
}
