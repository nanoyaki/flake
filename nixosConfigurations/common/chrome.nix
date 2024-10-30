{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkOption types mkIf;

  cfg = config.modules.chrome;
in

{
  options.modules.chrome = {
    allowSync = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to allow google account synchronisation.";
    };

    defaultBrowser = mkOption {
      type = types.bool;
      default = true;
      description = "Set as the default browser.";
    };

    extensions = mkOption {
      type = types.listOf types.str;
      default = [
        # General
        "oldceeleldhonbafppcapldpdifcinji" # LanguageTool
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "pbcodcjpfjdpcineamnnmbkkmkdpajjg" # Link to Text Fragment
        "kdbmhfkmnlmbkgbabkdealhhbfhlmmon" # SteamDB
        "jinjaccalgkegednnccohejagnlnfdag" # Violentmonkey
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "bkkmolkhemgaeaeggcmfbghljjjoofoh" # Catppuccin Mocha
        "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs offline
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
        "clngdbkpkpeebahjckkjfobafhncgmne" # Stylus
        "neebplgakaahbhdphmkckjjcegoiijjo" # Keepa - Amazon Price Tracker

        # Japanese
        "dpaojegkimhndjkkgiaookhckojbmakd" # Jisho-OJAD
        "fgnpplmalkhmcilpgbngpmdgfnodknce" # jisho-pitcher
        "kjpdbjocmacakdfnngpkfjcjlkieogcf" # Jisho On The Fly
        "odedgbgofldomjnodnnjdlagjpmkjhnb" # Search Jisho

        # Social media
        "ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
        "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
        "kfhgpagdjjoieckminnmigmpeclkdmjm" # Automatic Twitch
        "behhbpbpmailcnfbjagknjngnfdojpko" # Sky Follower Bridge
      ];
      description = "A list of extension to install for chrome.";
    };
  };

  config = {
    # Configure chrome
    programs.chromium = {
      enable = true;

      extraOpts = lib.mkMerge [
        {
          # https://chromeenterprise.google/policies/?policy=${OPTION}
          "BrowserSignin" = 0;
          "SyncDisabled" = true;
          "PasswordManagerEnabled" = false;
          "SpellcheckEnabled" = true;
          "RestoreOnStartup" = 1;
          "DeveloperToolsAvailability" = 1;
          "ForcedLanguages" = [
            "en-US"
            "de-DE"
            "ja-JP"
          ];
          "SpellcheckLanguage" = [
            "en-US"
            "de-DE"
            "ja-JP"
          ];
        }
        (mkIf cfg.allowSync {
          "BrowserSignin" = 1;
          "SyncDisabled" = false;
        })
      ];

      inherit (cfg) extensions;
    };

    programs.chromium.enablePlasmaBrowserIntegration = config.services.desktopManager.plasma6.enable;

    # Defaults
    xdg.mime.defaultApplications = mkIf cfg.defaultBrowser {
      # Browser
      "text/html" = "google-chrome.desktop";
      "text/css" = "google-chrome.desktop";
      "text/xml" = "google-chrome.desktop";
      "text/plain" = "google-chrome.desktop";
      "application/xhtml+xml" = "google-chrome.desktop";
      "application/xml" = "google-chrome.desktop";
      "application/atom+xml" = "google-chrome.desktop";
      "application/rss+xml" = "google-chrome.desktop";
      "application/pdf" = "google-chrome.desktop";
      "application/x-shockwave-flash" = "google-chrome.desktop";
      "application/x-dmg" = "google-chrome.desktop";
      "application/x-mobipocket-ebook" = "google-chrome.desktop";
      "application/epub+zip" = "google-chrome.desktop";
    };

    # Install chrome
    environment.systemPackages = with pkgs; [
      google-chrome
    ];

    environment.variables.BROWSER = mkIf cfg.defaultBrowser "google-chrome-stable";
  };
}
