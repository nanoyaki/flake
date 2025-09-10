{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    optionalString
    mkOption
    types
    ;

  cfg = config.services.stash;
  settingsFile = (pkgs.formats.yaml { }).generate "config.yml" cfg.settings;
in

{
  options.services.stash.scrapersCompat = mkOption {
    type = types.listOf types.package;
    default = [ ];
    description = ''
      The scrapers Stash should be started with.
    '';
    apply =
      srcs:
      pkgs.runCommand "stash-scrapers"
        {
          inherit srcs;
          nativeBuildInputs = [ pkgs.yq-go ];
          preferLocalBuild = true;
        }
        ''
          mkdir -p $out
          touch $out/.keep
          find $srcs -mindepth 1 -name '*.yml' | while read plugin_file; do
            grep -q "^#pkgignore" "$plugin_file" && continue

            plugin_dir=$(dirname $plugin_file)
            out_path=$out/$(basename $plugin_dir)
            mkdir -p $out_path
            ls $plugin_dir | xargs -I{} ln -sf "$plugin_dir/{}" $out_path

            env \
              plugin_id=$(basename $plugin_file .yml) \
              plugin_name="$(yq '.name' $plugin_file)" \
              plugin_description="$(yq '.description' $plugin_file)" \
              plugin_version="$(yq '.version' $plugin_file)" \
              plugin_files="$(find -L $out_path -mindepth 1 -type f -printf "%P\n")" \
              yq -n '
                .id = strenv(plugin_id) |
                .name = strenv(plugin_name) |
                (
                  strenv(plugin_description) as $desc |
                  with(select($desc == "null"); .metadata = {}) |
                  with(select($desc != "null"); .metadata.description = $desc)
                ) |
                (
                  strenv(plugin_version) as $ver |
                  with(select($ver == "null"); .version = "Unknown") |
                  with(select($ver != "null"); .version = $ver)
                ) |
                .date = (now | format_datetime("2006-01-02 15:04:05")) |
                .files = (strenv(plugin_files) | split("\n"))
              ' > $out_path/manifest
          done
          find $srcs -mindepth 1 -name 'py_common' -type d -exec ln -sf "{}" $out/py_common \;
        '';
  };

  config = {
    sops.secrets =
      lib.genAttrs
        [
          "stash/password"
          "stash/jwtSecret"
          "stash/sessionStoreSecret"
          "stash/shoko/user"
          "stash/shoko/pass"
          "stash/stashboxApiKey"
          "stash/apikey"
        ]
        (_: {
          owner = cfg.user;
        });

    sops.templates."config.json" = {
      file = (pkgs.formats.json { }).generate "config.json.template" {
        url = "https://shoko.theless.one:443";
        user = config.sops.placeholder."stash/shoko/user";
        pass = config.sops.placeholder."stash/shoko/pass";
      };
      owner = cfg.user;
      restartUnits = [ "stash.service" ];
    };

    sops.templates."ShokoAPI-config.ini" = {
      path = "${cfg.dataDir}/ShokoAPI-config.ini";
      content = ''
        url = https://stash.theless.one:443
        api_key = ${config.sops.placeholder."stash/apikey"}
      '';
      owner = cfg.user;
      restartUnits = [ "stash.service" ];
    };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir}/backups 0700 ${cfg.user} ${cfg.group} - -" ];

    services.stash = {
      enable = true;

      inherit (config.config'.lab-config.arr) group;
      passwordFile = config.sops.secrets."stash/password".path;
      jwtSecretKeyFile = config.sops.secrets."stash/jwtSecret".path;
      sessionStoreKeyFile = config.sops.secrets."stash/sessionStoreSecret".path;

      mutablePlugins = true;
      mutableScrapers = true;
      scrapersCompat = with pkgs.stashScrapers; [
        (shokoApi.override {
          configJSON = config.sops.templates."config.json".path;
        })
        aniDb
        hanime
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
        backup_directory_path = "${cfg.dataDir}/backups";
        ffprobe_path = lib.getExe' pkgs.ffmpeg-full "ffprobe";
        ffmpeg_path = lib.getExe pkgs.ffmpeg-full;
        python_path = lib.getExe (
          pkgs.python313.withPackages (
            pyPkgs: with pyPkgs; [
              requests
            ]
          )
        );
        scrapers_path = cfg.scrapersCompat;
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

    systemd.services.stash.serviceConfig.ExecStartPre = lib.mkForce (
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

    environment.systemPackages = [ pkgs.chromium ];

    config'.caddy.reverseProxies."https://stash.theless.one" = {
      inherit (cfg.settings) port;
      useMtls = true;
    };

    config'.homepage.categories.Media.services.Stash = rec {
      description = "Adult video server";
      icon = "stash.svg";
      href = "https://stash.theless.one";
      siteMonitor = href;
    };
  };
}
