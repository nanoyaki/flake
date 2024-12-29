{
  packages,
  config,
  ...
}:

{
  imports = [
    ../../../modules/lavalink
  ];

  services.lavalink = {
    enable = true;
    enableHttp2 = true;
    password = "s3cRe!p4SsW0rD";
    package = packages.lavalink;
    port = 2333;
    plugins = [
      {
        name = "youtube";
        dependency = "dev.lavalink.youtube:youtube-plugin:1.8.0";
        snapshot = false;
        hash = "sha256-gQKwwto+PvB/Ucb1kmvfng6A/hfoFynB3bRwmT09ogc=";
        extraConfig = {
          enabled = true;
          allowSearch = true;
          allowDirectVideoIds = true;
          allowDirectPlaylistIds = true;
          # Available clients:
          # https://github.com/lavalink-devs/youtube-source?tab=readme-ov-file#available-clients
          clients = [
            "MUSIC"
            "ANDROID_TESTSUITE"
            "WEB"
            "WEBEMBEDDED"
            "ANDROID_MUSIC"
            "TVHTML5EMBEDDED"
          ];
        };
      }
      {
        dependency = "com.github.topi314.sponsorblock:sponsorblock-plugin:3.0.1";
        snapshot = false;
        hash = "sha256-kVDukbe6AJalLuKfBB8lvF0l91d7p4/IB0oQxlfWjbQ=";
      }
      {
        name = "lavasrc";
        dependency = "com.github.topi314.lavasrc:lavasrc-plugin:4.2.0";
        repository = "https://maven.lavalink.dev/releases";
        snapshot = false;
        hash = "sha256-NoyRphbDPWLnu7LO90NMqECUnm3/h/kiQHnQNZiMofU=";
        extraConfig = {
          providers = [ "ytsearch:%QUERY%" ];
        };
      }
    ];
    extraConfig = {
      lavalink.server = {
        sources = {
          # Default youtube is deprecated
          youtube = false;
          bandcamp = true;
          soundcloud = true;
          twitch = true;
          vimeo = true;
          nico = true;
          # warning: keeping HTTP enabled without a proxy
          # configured could expose your server's IP address.
          http = false;
        };

        filters = {
          volume = true;
          equalizer = true;
          karaoke = true;
          timescale = true;
        };

        # Least to most expensive
        # 0-10
        opusEncodingQuality = 10;
        resamplingQuality = "HIGH";
        trackStuckThresholdMs = 10000;
        useSeekGhosting = true;

        # Number of pages at 100 each
        youtubePlaylistLoadLimit = 6;
        playerUpdateInterval = 5;
        youtubeSearchEnabled = true;
        soundcloudSearchEnabled = true;
        gc-warnings = true;

        # Squid has major sequirity vulnerabilities
        # httpConfig = {
        #   proxyHost = "localhost";
        #   proxyPort = 3128;
        # };
      };

      metrics.prometheus = {
        enabled = false;
        endpoint = "/metrics";
      };

      logging = {
        level.lavalink = "INFO";
        request = {
          enabled = true;
          includeClientInfo = true;
          includeHeaders = false;
          includeQueryString = true;
          includePayload = false;
          maxPayloadLength = 10000;
        };
      };
    };
  };

  services.prometheus = {
    enable = false;
    port = 9090;
    globalConfig.scrape_interval = "10s"; # "1m"
    scrapeConfigs = [
      {
        job_name = "lavalink";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.lavalink.port}"
            ];
          }
        ];
      }
    ];
  };
}
