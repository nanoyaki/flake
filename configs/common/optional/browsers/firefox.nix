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

  icon =
    if
      (
        config.nanoflake ? theme && config.nanoflake.theme.iconPackage.pname == "catppuccin-papirus-folders"
      )
    then
      "${config.nanoflake.theme.iconPackage}/share/icons/Papirus-Dark/128x128/apps/nix-snowflake.svg"
    else
      "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  defaultBrowserApp = lib'.mapDefaultForMimeTypes config.programs.firefox.package [
    "text/html"
    "text/css"
    "text/xml"
    "application/xhtml+xml"
    "application/xml"
    "application/atom+xml"
    "application/rss+xml"
    "application/pdf"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
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
      wrapperConfig.pipewireSupport = true;

      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.location" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
        "widget.use-xdg-desktop-portal.native-messaging" = 1;
        "widget.use-xdg-desktop-portal.open-uri" = 1;
        "widget.use-xdg-desktop-portal.settings" = 1;
        "middlemouse.paste" = false;
      };
    };

    xdg.mime.defaultApplications = mkIf cfg.defaultBrowser defaultBrowserApp;
    hm.xdg.mimeApps.defaultApplications = mkIf cfg.defaultBrowser defaultBrowserApp;

    environment.variables = mkIf cfg.defaultBrowser {
      BROWSER = lib.getExe config.programs.firefox.package;
    };

    hm.programs.firefox = {
      enable = true;
      inherit (config.programs.firefox) package;

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;
        search = {
          force = true;
          default = "google";
          privateDefault = "ddg";
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              inherit icon;
              definedAliases = [ "@np" ];
            };

            "Nix Options" = {
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              inherit icon;
              definedAliases = [ "@no" ];
            };

            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://wiki.nixos.org/w/index.php";
                  params = [
                    {
                      name = "search";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              inherit icon;
              definedAliases = [ "@nw" ];
            };
          };
        };
        extensions = {
          force = true;
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            keepa
            refined-github
            languagetool
            control-panel-for-twitter
            tampermonkey
            redirector
            reddit-enhancement-suite
            mullvad

            steam-database
            augmented-steam

            return-youtube-dislikes
            youtube-screenshot-button

            seventv
            betterttv
            twitch-auto-points
          ];
        };
      };

      profiles.vpn = {
        id = 1;
        name = "vpn";
        isDefault = false;
        search = {
          force = true;
          default = "google";
          privateDefault = "ddg";
        };
        extensions = {
          force = true;
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            mullvad
          ];
        };
      };
    };
  };
}
