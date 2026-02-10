{ withSystem, ... }:

{
  perSystem =
    { pkgs, ... }:

    {
      packages.solaar = pkgs.symlinkJoin {
        inherit (pkgs.solaar) pname version;
        paths = [ pkgs.solaar ];
        postBuild = ''
          cp $out/share/applications/solaar.desktop solaar.desktop
          rm $out/share/applications/solaar.desktop

          substitute solaar.desktop $out/share/applications/solaar.desktop \
            --replace-fail "solaar" 'solaar -w hide'

          ln -s ${pkgs.solaar.udev} $udev
        '';
        outputs = [
          "out"
          "udev"
        ];
      };
    };

  flake.overlays.solaar =
    _: prev:

    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:

      {
        inherit (config.packages) solaar;
      }
    );

  flake.nixosModules.shirayuri-desktop =
    { pkgs, config, ... }:

    {
      environment.systemPackages = [
        pkgs.vesktop
      ];

      environment.sessionVariables.BROWSER = config.programs.firefox.package.meta.mainProgram;

      xdg.mime.defaultApplications = {
        "text/html" = "librewolf.desktop";
        "application/pdf" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
      };
    };

  flake.homeModules.hana-desktop =
    { pkgs, config, ... }:

    let
      inherit (config.lib.file) mkOutOfStoreSymlink;
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    in

    {
      xdg.autostart.entries = [
        "${pkgs.solaar}/share/applications/solaar.desktop"
        "${pkgs.vesktop}/share/applications/vesktop.desktop"
      ];

      catppuccin.thunderbird.profile = "default";
      programs.thunderbird = {
        enable = true;

        profiles.default.isDefault = true;
        profiles.default.withExternalGnupg = true;

        profiles.transacademy = {
          inherit (config.programs.thunderbird.profiles.default) extensions;
          withExternalGnupg = true;
        };
      };

      programs.librewolf = {
        enable = true;
        languagePacks = [
          "en-GB"
          "de"
        ];

        policies = {
          DontCheckDefaultBrowser = true;
          DisablePocket = true;
          DisableAppUpdate = true;
        };

        # https://github.com/hlissner/dotfiles/blob/28b2f8889c7a8d799c62dbab3729b1de18c6c1a5/modules/desktop/browsers/librewolf.nix
        settings = {
          # Allow svgs to take on theme colors
          "svg.context-properties.content.enabled" = true;
          "webgl.disabled" = false;
          # Neat feature, but i need dark mode
          "privacy.resistFingerprinting" = false;
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
          "privacy.donottrackheader.enabled" = true;
          "privacy.donottrackheader.value" = 1;
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

        profiles.default = {
          id = 0;
          name = "default";
          isDefault = true;
          search = {
            force = true;
            default = "ddg";
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

              "Noogle" = {
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
      };

      nixpkgs.allowUnfreeNames = [
        "keepa"
        "languagetool"
        "tampermonkey"
        "betterttv"
      ];

      xdg.mimeApps.defaultApplications = {
        "text/html" = "librewolf.desktop";
        "application/pdf" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
      };

      programs.mpv = {
        enable = true;

        config = {
          osc = "no";
          volume = 40;
        };

        scripts = with pkgs.mpvScripts; [
          sponsorblock
          thumbfast
          modernx
          mpvacious
          mpv-discord
          mpv-subtitle-lines
          mpv-playlistmanager
          mpv-cheatsheet
        ];
      };

      xdg.mimeApps.defaultApplications = {
        "audio/*" = "mpv.desktop";
        "video/*" = "mpv.desktop";
      };

      xdg.autostart.enable = true;

      xdg.userDirs = {
        enable = true;

        desktop = "/home/hana/Desktop";
        download = "/mnt/os-shared/Downloads";
        documents = "/mnt/os-shared/Documents";
        videos = "/mnt/os-shared/Videos";
        pictures = "/mnt/os-shared/Pictures";
        music = "/mnt/os-shared/Music";

        publicShare = null;
        templates = null;
      };

      home.file = {
        Downloads.source = mkOutOfStoreSymlink "/mnt/os-shared/Downloads";
        Documents.source = mkOutOfStoreSymlink "/mnt/os-shared/Documents";
        Videos.source = mkOutOfStoreSymlink "/mnt/os-shared/Videos";
        Pictures.source = mkOutOfStoreSymlink "/mnt/os-shared/Pictures";
        Music.source = mkOutOfStoreSymlink "/mnt/os-shared/Music";

        os-shared.source = mkOutOfStoreSymlink "/mnt/os-shared";
      };
    };
}
