let
  settings = {
    # Allow svgs to take on theme colors
    "svg.context-properties.content.enabled" = true;
    "webgl.disabled" = false;
    # Neat feature, but i need dark mode
    "privacy.resistFingerprinting" = false;
    "privacy.fingerprintingProtection" = false;
    "privacy.fingerprintingProtection.pbmode" = false;
    # Fuck AI
    "browser.ml.chat.enabled" = false;

    # Obey XDG
    "widget.use-xdg-desktop-portal.file-picker" = 1;
    "widget.use-xdg-desktop-portal.location" = 1;
    "widget.use-xdg-desktop-portal.mime-handler" = 1;
    "widget.use-xdg-desktop-portal.native-messaging" = 1;
    "widget.use-xdg-desktop-portal.open-uri" = 1;
    "widget.use-xdg-desktop-portal.settings" = 1;

    # Autoscroll
    "general.autoscroll" = true;
    "middlemouse.paste" = false;

    # Security
    "security.family_safety.mode" = 0;
    "security.pki.sha1_enforcement_level" = 1;
    "security.tls.enable_0rtt_data" = false;
    "geo.provider.network.url" =
      "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
    "geo.provider.use_gpsd" = false;

    # We set BROWSER already
    "browser.shell.checkDefaultBrowser" = false;
    # Disable these default extensions
    "extensions.pocket.enabled" = false;
    "extensions.unifiedExtensions.enabled" = false;
    "extensions.shield-recipe-client.enabled" = false;
    # Disable telemetry
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.server" = "data:,";
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.coverage.opt-out" = true;
    "toolkit.coverage.opt-out" = true;
    "toolkit.coverage.endpoint.base" = "";
    "experiments.supported" = false;
    "experiments.enabled" = false;
    "experiments.manifest.uri" = "";
    "browser.ping-centre.telemetry" = false;
    # Disable crash reports
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;
    "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
    # Don't log out
    "privacy.clearOnShutdown.cookies" = false;
    "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
    "privacy.clearOnShutdown.sessions" = false;

    # Buttons have dedicated shortcuts
    "browser.toolbars.keyboard_navigation" = false;
    # I'll translate whenever i want
    "browser.translations.automaticallyPopup" = false;
    # Privacy options
    "browser.contentblocking.category" = "strict";
    "privacy.donottrackheader.enabled" = false;
    "privacy.purge_trackers.enabled" = true;
    # Blank new tab
    "browser.newtabpage.enabled" = false;
    "browser.newtab.url" = "about:blank";
    "browser.newtabpage.enhanced" = false;
    "browser.newtabpage.introShown" = true;
    "browser.newtab.preload" = false;
    "browser.newtabpage.directory.ping" = "";
    "browser.newtabpage.directory.source" = "data:text/plain,{}";
    # No need for ads
    "browser.newtabpage.activity-stream.enabled" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    # Am aware of the following
    "browser.aboutConfig.showWarning" = false;
    # Disable PiP
    "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
    # Disable form autfill
    "browser.formfill.enable" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.available" = "off";
    "extensions.formautofill.creditCards.available" = false;
    "extensions.formautofill.creditCards.enabled" = false;
    "extensions.formautofill.heuristics.enabled" = false;
    # Cosmic themeing
    "widget.gtk.libadwaita-colors.enabled" = false;
  };

  policies = {
    DontCheckDefaultBrowser = true;
    DisablePocket = true;
    DisableAppUpdate = true;
    DisableTelemetry = true;
    PasswordManagerEnabled = false;
  };
in

{
  flake.nixosModules.shirayuri-firefox =
    {
      lib,
      pkgs,
      config,
      ...
    }:

    {
      # Manage through home-manager
      programs.firefox.enable = false;
      environment.systemPackages = [ pkgs.firefox ];
      environment.sessionVariables.BROWSER = config.programs.firefox.package.meta.mainProgram;

      programs.firefox.nativeMessagingHosts.packages =
        lib.optionals config.services.desktopManager.plasma6.enable
          [ pkgs.kdePackages.plasma-browser-integration ];

      xdg.mime.defaultApplications = {
        "text/html" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };

  flake.homeModules.hana-firefox =
    {
      pkgs,
      config,
      ...
    }:

    let
      icon = "${pkgs.papirus-icon-theme}/share/icons/Papirus/64x64/apps/nix-snowflake.svg";
    in

    {
      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
        languagePacks = [
          "en-GB"
          "de"
        ];

        inherit policies;

        profiles.default = {
          id = 0;
          name = "default";
          isDefault = true;

          inherit settings;
          search = {
            force = true;
            default = "ddg";
            privateDefault = "ddg";

            engines = {
              nixpkgs = {
                name = "Nixpkgs";
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

              nixos-options = {
                name = "NixOS Options";
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

              nixos-wiki = {
                name = "NixOS Wiki";
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

              noogle = {
                name = "Noogle";
                urls = [
                  {
                    template = "https://noogle.dev/q";
                    params = [
                      {
                        name = "term";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];

                inherit icon;
                definedAliases = [ "@nf" ];
              };

              nix-code = {
                name = "Nix Code";
                urls = [
                  {
                    template = "https://github.com/search";
                    params = [
                      {
                        name = "type";
                        value = "code";
                      }
                      {
                        name = "q";
                        value = "language:Nix%20AND%20NOT%20repo:NixOS/nixpkgs%20{searchTerms}";
                      }
                    ];
                  }
                ];

                inherit icon;
                definedAliases = [ "@nc" ];
              };
            };
          };

          extensions.force = true;
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            refined-github
            languagetool
            control-panel-for-twitter
            violentmonkey
            redirector
            reddit-enhancement-suite
            steam-database
            augmented-steam
            return-youtube-dislikes
            seventv
            ublock-origin
            mullvad
            bitwarden
          ];
        };

        profiles.vpn = {
          id = 1;
          name = "vpn";

          inherit settings;
          search = {
            force = true;
            default = "ddg";
            privateDefault = "ddg";
          };

          extensions.force = true;
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            mullvad
            bitwarden
          ];
        };
      };

      xdg.mimeApps.defaultApplications = {
        "text/html" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };

      home.sessionVariables.BROWSER = config.programs.firefox.package.meta.mainProgram;

      nixpkgs.allowUnfreeNames = [ "languagetool" ];
    };
}
