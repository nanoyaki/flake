{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) optionalString;

  cfg = config.services.stash;
  settingsFile = (pkgs.formats.yaml { }).generate "config.yml" cfg.settings;
in

{
  sops.secrets =
    lib.genAttrs
      [
        "stash/password"
        "stash/jwtSecret"
        "stash/sessionStoreSecret"
        "stash/shoko/user"
        "stash/shoko/pass"
        "stash/stashboxApiKey"
      ]
      (_: {
        owner = cfg.user;
      });

  sops.templates."config.json".file = (pkgs.formats.json { }).generate "config.json.template" {
    url = "https://shoko.vpn.theless.one";
    user = config.sops.placeholder."stash/shoko/user";
    pass = config.sops.placeholder."stash/shoko/pass";
  };

  services.stash = {
    enable = true;

    group = "arr-stack";
    passwordFile = config.sops.secrets."stash/password".path;
    jwtSecretKeyFile = config.sops.secrets."stash/jwtSecret".path;
    sessionStoreKeyFile = config.sops.secrets."stash/sessionStoreSecret".path;

    mutablePlugins = true;
    scrapers = with pkgs.stashScrapers; [
      (shokoApi.override {
        configJSON = config.sops.templates."config.json".path;
      })
      aniDb
      hanime
      py-common
    ];

    username = "administrator";
    settings = {
      host = "127.0.0.1";
      stash = [
        {
          path = "/mnt/raid/arr-stack/libraries/anime/hentai";
        }
        {
          path = "/mnt/raid/arr-stack/libraries/adult";
        }
      ];
      python_path = lib.getExe (
        pkgs.python313.withPackages (
          pyPkgs: with pyPkgs; [
            requests
          ]
        )
      );
      stash_boxes = [
        {
          name = "StashDB";
          endpoint = "https://stashdb.org/graphql";
          apikey = "to-be-replaced-by-out-of-store-file";
        }
      ];

      calculate_md5 = true;
      create_image_clip_from_videos = true;

      menu_items = [
        "scenes"
        "images"
        "groups"
        "markers"
        "galleries"
        "performers"
        "studios"
        "tags"
      ];

      scraper_user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:139.0) Gecko/20100101 Firefox/139.0";
      scraper_cdp_path = lib.getExe pkgs.ungoogled-chromium;

      ui = {
        advancedMode = true;
        enableMovieBackgroundImage = true;
        enableStudioBackgroundImage = true;
        enableTagBackgroundImage = true;

        taskDefaults.generate = {
          clipPreviews = true;
          covers = true;
          imagePreviews = true;
          imageThumbnails = true;
          interactiveHeatmapsSpeeds = true;
          markerImagePreviews = true;
          markerScreenshots = true;
          markers = true;
          overwrite = false;
          phashes = true;
          previewOptions = {
            previewExcludeEnd = "0";
            previewExcludeStart = "0";
            previewPreset = "slow";
            previewSegmentDuration = 0.75;
            previewSegments = 12;
          };
          previews = true;
          sprites = true;
          transcodes = true;
        };

        taskDefaults.scan = {
          rescan = false;
          scanGenerateClipPreviews = true;
          scanGenerateCovers = true;
          scanGenerateImagePreviews = true;
          scanGeneratePhashes = true;
          scanGeneratePreviews = true;
          scanGenerateSprites = true;
          scanGenerateThumbnails = true;
        };
      };

      defaults.identify_task = {
        options = {
          fieldoptions = [
            {
              createmissing = null;
              field = "title";
              strategy = "OVERWRITE";
            }
            {
              createmissing = true;
              field = "studio";
              strategy = "MERGE";
            }
            {
              createmissing = true;
              field = "performers";
              strategy = "MERGE";
            }
            {
              createmissing = true;
              field = "tags";
              strategy = "MERGE";
            }
          ];
          includemaleperformers = true;
          setcoverimage = true;
          setorganized = false;
          skipmultiplematches = true;
          skipmultiplematchtag = null;
          skipsinglenameperformers = true;
          skipsinglenameperformertag = null;
        };
        paths = [ ];
        sceneids = [ ];
        sources = [
          {
            options = null;
            source = {
              scraperid = null;
              stashboxendpoint = "https://stashdb.org/graphql";
              stashboxindex = null;
            };
          }
          {
            options = null;
            source = {
              scraperid = "ShokoAPI";
              stashboxendpoint = null;
              stashboxindex = null;
            };
          }
          {
            options = null;
            source = {
              scraperid = "AniDB";
              stashboxendpoint = null;
              stashboxindex = null;
            };
          }
          {
            options = null;
            source = {
              scraperid = "hanime";
              stashboxendpoint = null;
              stashboxindex = null;
            };
          }
          {
            options = {
              fieldoptions = [ ];
              includemaleperformers = null;
              setcoverimage = null;
              setorganized = false;
              skipmultiplematches = true;
              skipmultiplematchtag = null;
              skipsinglenameperformers = true;
              skipsinglenameperformertag = null;
            };
            source = {
              scraperid = "builtin_autotag";
              stashboxendpoint = null;
              stashboxindex = null;
            };
          }
        ];
      };
    };
  };

  systemd.services.stash = {
    requires = [ "mnt-raid.mount" ];
    after = [ "mnt-raid.mount" ];
    bindsTo = [ "mnt-raid.mount" ];

    serviceConfig.ExecStartPre = lib.mkForce (
      pkgs.writers.writeBash "stash-setup.bash" (
        ''
          install -d ${cfg.settings.generated}
          if [[ -z "${toString cfg.mutableSettings}" || ! -f ${cfg.dataDir}/config.yml ]]; then
            env \
              password=$(< ${cfg.passwordFile}) \
              jwtSecretKeyFile=$(< ${cfg.jwtSecretKeyFile}) \
              sessionStoreKeyFile=$(< ${cfg.sessionStoreKeyFile}) \
              stashBoxApiKeyFile=$(< ${config.sops.secrets."stash/stashboxApiKey".path}) \
              ${lib.getExe pkgs.yq-go} '
                .jwt_secret_key = strenv(jwtSecretKeyFile) |
                .session_store_key = strenv(sessionStoreKeyFile) |
                .stash_boxes[0].apikey = strenv(stashBoxApiKeyFile) |
                (
                  strenv(password) as $password |
                  with(select($password != ""); .password = $password)
                )
              ' ${settingsFile} > ${cfg.dataDir}/config.yml
          fi
        ''
        + optionalString cfg.mutablePlugins ''
          install -d ${cfg.settings.plugins_path}
          ls ${cfg.plugins} | xargs -I{} ln -sf '${cfg.plugins}/{}' ${cfg.settings.plugins_path}
        ''
        + optionalString cfg.mutableScrapers ''
          install -d ${cfg.settings.scrapers_path}
          ls ${cfg.scrapers} | xargs -I{} ln -sf '${cfg.scrapers}/{}' ${cfg.settings.scrapers_path}
        ''
      )
    );
  };

  environment.systemPackages = [ pkgs.chromium ];

  config'.caddy.reverseProxies."https://stash.vpn.theless.one" = {
    inherit (cfg.settings) port;
    vpnOnly = true;
  };

  config'.homepage.categories.Media.services.Stash = rec {
    description = "Adult video server";
    icon = "stash.svg";
    href = "https://stash.vpn.theless.one";
    siteMonitor = href;
  };
}
