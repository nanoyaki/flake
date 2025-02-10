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
    mkEnableOption
    types
    mkIf
    ;

  cfg = config.nanoflake.firefox;

  mkAddon = installMode: id: {
    installation_mode = "${installMode}";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
  };

  mkNormal = id: mkAddon "normal_installed" id;

  mkForce = id: mkAddon "force_installed" id;

  defaultBrowserApp = lib'.mapDefaultForMimeTypes pkgs.firefox [
    "text/html"
    "text/css"
    "text/xml"
    "application/xhtml+xml"
    "application/xml"
    "application/atom+xml"
    "application/rss+xml"
    "application/pdf"
  ];
in

{
  options.nanoflake.firefox = {
    enablePolicies = mkEnableOption "firefox policies";

    defaultBrowser = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = "Whether to set firefox as the default browser";
    };
  };

  config = {
    programs.firefox = {
      enable = true;

      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.location" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
        "widget.use-xdg-desktop-portal.native-messaging" = 1;
        "widget.use-xdg-desktop-portal.open-uri" = 1;
        "widget.use-xdg-desktop-portal.settings" = 1;
      };

      policies = mkIf cfg.enablePolicies {
        Homepage.StartPage = "previous-session";
        PasswordManagerEnabled = false;
        # nix run nixpkgs#jq -- -r '.guid' $(curl https://addons.mozilla.org/api/v5/addons/addon/<ID>/)
        ExtensionSettings = {
          # Utilities
          "uBlock0@raymondhill.net" = mkForce "ublock-origin";
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = mkNormal "bitwarden-password-manager";
          "languagetool-webextension@languagetool.org" = mkNormal "languagetool";
          "{c13e9f22-6988-4543-86b9-b71bc7e71560}" = mkNormal "link-to-text-fragment";

          # Social media specific
          "firefox@betterttv.net" = mkNormal "betterttv";
          "sponsorBlocker@ajay.app" = mkNormal "sponsorblock";
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = mkNormal "return-youtube-dislikes";
          "sky-follower-bridge@ryo.kawamata" = mkNormal "sky-follower-bridge";
          "addon@darkreader.org" = mkNormal "darkreader";

          # Site enhancements
          "{a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad}" = mkNormal "refined-github-";
          "firefox-extension@steamdb.info" = mkNormal "steam-database";
          "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = mkNormal "augmented-steam";
          "amptra@keepa.com" = mkNormal "keepa";

          # Japanese
          "{68f6708f-9add-454c-9185-0bb646ed20bb}" = mkNormal "jisho-ojad";
          "{61dff19a-4460-42de-9825-1ed4f0813091}" = mkNormal "pitcher";
          "{77021898-c4f9-4a7d-94b7-6d1562ea0b1c}" = mkNormal "search-jisho";
        };
      };
    };

    xdg.mime.defaultApplications = mkIf cfg.defaultBrowser defaultBrowserApp;
    hm.xdg.mimeApps.defaultApplications = mkIf cfg.defaultBrowser defaultBrowserApp;

    environment.variables = mkIf cfg.defaultBrowser { BROWSER = lib.getExe pkgs.firefox; };
  };
}
