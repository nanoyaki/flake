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

      extensions = [
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
        # "jgejdcdoeeabklepnkdbglgccjpdgpmf" # Old Twitter Layout (2024)
        "kbmfpngjjgdllneeigpgjifpgocmfgmb" # Reddit Enhancement Suite
        "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
        "kfhgpagdjjoieckminnmigmpeclkdmjm" # Automatic Twitch
      ];
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

    environment.systemPackages = with pkgs; [
      chromium
    ];

    environment.sessionVariables.BROWSER = mkIf cfg.defaultBrowser "chromium";
  };
}
