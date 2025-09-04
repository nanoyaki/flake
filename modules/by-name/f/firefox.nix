{
  lib,
  lib',
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib'.options) mkFalseOption;

  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
in

{
  options.config'.firefox.enable = mkFalseOption;

  config = mkIf config.config'.firefox.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.librewolf;
      wrapperConfig.pipewireSupport = true;

      policies = {
        DontCheckDefaultBrowser = true;
        DisablePocket = true;
        DisableAppUpdate = true;
      };

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

    environment.sessionVariables.BROWSER = config.programs.firefox.package.meta.mainProgram;

    xdg.mime.addedAssociations = {
      "text/html" = "LibreWolf.desktop";
      "application/pdf" = "LibreWolf.desktop";
      "x-scheme-handler/http" = "LibreWolf.desktop";
      "x-scheme-handler/https" = "LibreWolf.desktop";
    };

    hms = lib.singleton {
      programs.firefox = {
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
  };
}
