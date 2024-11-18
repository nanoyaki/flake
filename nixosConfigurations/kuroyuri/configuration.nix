{ ... }:

{
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
  ];

  system.stateVersion = "24.05";
}
