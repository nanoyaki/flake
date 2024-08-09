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
        "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # Google Docs offline

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
    # Configure chrome
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
      "text/html" = "chromium.desktop";
      "text/css" = "chromium.desktop";
      "text/xml" = "chromium.desktop";
      "text/plain" = "chromium.desktop";
      "application/xhtml+xml" = "chromium.desktop";
      "application/xml" = "chromium.desktop";
      "application/json" = "chromium.desktop";
      "application/javascript" = "chromium.desktop";
      "application/atom+xml" = "chromium.desktop";
      "application/rss+xml" = "chromium.desktop";
      "application/pdf" = "chromium.desktop";
      "application/x-shockwave-flash" = "chromium.desktop";
      "application/x-dmg" = "chromium.desktop";
      "application/x-mobipocket-ebook" = "chromium.desktop";
      "application/epub+zip" = "chromium.desktop";
    };

    # Install chrome
    environment.systemPackages = with pkgs; [
      chromium
      google-chrome
    ];

    environment.sessionVariables.BROWSER = mkIf cfg.defaultBrowser "chromium";
  };
}
