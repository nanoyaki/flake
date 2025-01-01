{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    mkPackageOption
    types
    mkIf
    ;

  cfg = config.modules.chrome;

  extensionMap = {
    # General
    languageTool = "oldceeleldhonbafppcapldpdifcinji";
    bitwarden = "nngceckbapebfimnlniiiahkandclblb";
    linkToTextFragment = "pbcodcjpfjdpcineamnnmbkkmkdpajjg";
    steamDb = "kdbmhfkmnlmbkgbabkdealhhbfhlmmon";
    violentmonkey = "jinjaccalgkegednnccohejagnlnfdag";
    ublockOrigin = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
    googleDocsOffline = "ghbmnnjooekpmoecnnnilnnbdlolhkhi";
    darkReader = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
    keepaAmazonPriceTracker = "neebplgakaahbhdphmkckjjcegoiijjo";

    # Theming
    catppuccinMocha = "bkkmolkhemgaeaeggcmfbghljjjoofoh";
    stylus = "clngdbkpkpeebahjckkjfobafhncgmne";

    # Japanese
    jishoOjad = "dpaojegkimhndjkkgiaookhckojbmakd";
    jisho-pitcher = "fgnpplmalkhmcilpgbngpmdgfnodknce";
    jishoOnTheFly = "kjpdbjocmacakdfnngpkfjcjlkieogcf";
    searchJisho = "odedgbgofldomjnodnnjdlagjpmkjhnb";
    migaku = "lkhiljgmbeecmljiogckofcalncmfnfo";

    # Social media
    betterTtv = "ajopnjidmegmdimjlfnijceegpefgped";
    returnYoutubeDislike = "gebbhagfogifgggkldgodflihgfeippi";
    sponsorBlock = "mnjggcdmjocbbbhaepdhchncahnbgone";
    automaticTwitch = "kfhgpagdjjoieckminnmigmpeclkdmjm";
    skyFollowerBridge = "behhbpbpmailcnfbjagknjngnfdojpko";
  };

  defaultBrowserApp = lib'.mapDefaultForMimeTypes [
    "text/html"
    "text/css"
    "text/xml"
    "application/xhtml+xml"
    "application/xml"
    "application/atom+xml"
    "application/rss+xml"
    "application/pdf"
  ] cfg.chromePackage;
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
      type = types.listOf (types.enum (builtins.attrNames extensionMap));
      default = [ ];
      description = "A list of extension to install for chrome.";
    };

    chromePackage = mkPackageOption pkgs "google-chrome" { };
  };

  config = {
    # Configure chrome
    programs.chromium = {
      enable = true;

      extraOpts = {
        # https://chromeenterprise.google/policies/?policy=${OPTION}
        BrowserSignin = if cfg.allowSync then 1 else 0;
        SyncDisabled = !cfg.allowSync;
        PasswordManagerEnabled = false;
        SpellcheckEnabled = true;
        RestoreOnStartup = 1;
        DeveloperToolsAvailability = 1;
        ForcedLanguages = [
          "en-US"
          "de-DE"
          "ja-JP"
        ];
        SpellcheckLanguage = [
          "en-US"
          "de-DE"
          "ja-JP"
        ];
      };

      extensions = builtins.map (attrName: extensionMap.${attrName}) cfg.extensions;
      enablePlasmaBrowserIntegration = config.services.desktopManager.plasma6.enable;
    };

    # Defaults
    xdg.mime.defaultApplications = mkIf cfg.defaultBrowser defaultBrowserApp;
    hm.xdg.mimeApps.defaultApplications = mkIf cfg.defaultBrowser defaultBrowserApp;

    # Install chrome
    environment.systemPackages = [ cfg.chromePackage ];
    environment.variables.BROWSER = mkIf cfg.defaultBrowser "google-chrome-stable";
  };
}
