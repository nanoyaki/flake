{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.nano.chrome;
in {
  options.services.nano.chrome = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom mpv options.";
    };

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
        "cmpdlhmnmjhihmcfnigoememnffkimlk" # Catppuccin Macchiato

        # Japanese
        "dpaojegkimhndjkkgiaookhckojbmakd" # Jisho-OJAD
        "fgnpplmalkhmcilpgbngpmdgfnodknce" # jisho-pitcher
        "kjpdbjocmacakdfnngpkfjcjlkieogcf" # Jisho On The Fly
        "odedgbgofldomjnodnnjdlagjpmkjhnb" # Search Jisho

        # Social media
        "ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
        "jgejdcdoeeabklepnkdbglgccjpdgpmf" # Old Twitter Layout (2024)
        "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Reddit Enhancement Suite
        "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
        "kfhgpagdjjoieckminnmigmpeclkdmjm" # Automatic Twitch
      ];
      description = "A list of extension to install for chrome.";
    };
  };

  config = mkIf cfg.enable {
    # Install chromium
    programs.chromium = {
      enable = true;

      extraOpts = mkMerge [
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

      extensions = cfg.extensions;
    };

    # Defaults
    xdg.mime.defaultApplications = mkIf cfg.defaultBrowser {
      # Browser
      "text/html" = "google-chrome.desktop";
      "text/css" = "google-chrome.desktop";
      "text/xml" = "google-chrome.desktop";
      "text/plain" = "google-chrome.desktop";
      "application/xhtml+xml" = "google-chrome.desktop";
      "application/xml" = "google-chrome.desktop";
      "application/json" = "google-chrome.desktop";
      "application/javascript" = "google-chrome.desktop";
      "application/atom+xml" = "google-chrome.desktop";
      "application/rss+xml" = "google-chrome.desktop";
      "application/pdf" = "google-chrome.desktop";
      "application/x-shockwave-flash" = "google-chrome.desktop";
      "application/x-dmg" = "google-chrome.desktop";
      "application/x-mobipocket-ebook" = "google-chrome.desktop";
      "application/epub+zip" = "google-chrome.desktop";
    };

    environment.systemPackages = with pkgs; [
      google-chrome
    ];

    environment.sessionVariables.BROWSER = mkIf cfg.defaultBrowser "google-chrome";
  };
}
