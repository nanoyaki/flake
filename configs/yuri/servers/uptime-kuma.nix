{
  lib,
  pkgs,
  config,
  ...
}:

let
  defaults = {
    enabled = true;
    interval = "5m";
    method = "GET";
    conditions = [
      "[STATUS] == 200"
      "[RESPONSE_TIME] < 1000"
    ];
  };

  alertDefaults = description: {
    alerts = [
      (
        {
          type = "discord";
        }
        // lib.optionalAttrs (description != null) {
          inherit description;
        }
      )
    ];
  };

  arrDefaults =
    service:
    defaults
    // {
      name = service;
      url = "https://${lib.toLower service}.theless.one";
      group = "Arr";
      alerts = [
        {
          type = "discord";
          description = ''''$${lib.toUpper service}_ALERT_DESCR'';
        }
      ];
    };

  arrServices = [
    "Sabnzbd"
    "Flood"
    "Bazarr"
    "Lidarr"
    "Radarr"
    "Sonarr"
    "Shoko"
    "Whisparr"
    "Prowlarr"
    "Jellyseerr"
    "Jellyfin"
    "Stash"
    "Audiobookshelf"
  ];

  notify = "Please notify <@1063583541641871440> if she isn't aware already";
in

{
  sops.secrets = {
    "gatus/mtls-cert" = { };
    "gatus/mtls-key" = { };
    "gatus/discord-webhook-url" = { };
  }
  // lib.genAttrs' arrServices (service: lib.nameValuePair "gatus/alert/${lib.toLower service}" { });

  sops.templates."gatus.env".file = (pkgs.formats.keyValue { }).generate "gatus.env.template" (
    {
      DISCORD_WEBHOOK_URL = config.sops.placeholder."gatus/discord-webhook-url";
    }
    // lib.genAttrs' arrServices (
      service:
      lib.nameValuePair "${lib.toUpper service}_ALERT_DESCR"
        config.sops.placeholder."gatus/alert/${lib.toLower service}"
    )
  );

  systemd.services.gatus.serviceConfig.EnvironmentFile = config.sops.templates."gatus.env".path;

  services.gatus = {
    enable = true;

    settings = {
      web.port = 4000;

      maintenance = {
        enabled = true;
        start = "04:00";
        duration = "30m";
        timezone = "Europe/Berlin";
        every = [ ];
      };

      alerting.discord = {
        webhook-url = "$DISCORD_WEBHOOK_URL";
        title = "A service health check failed";
        default-alert = {
          send-on-resolved = true;
          failure-threshold = 1;
          success-threshold = 1;
        };
      };

      client = {
        tls.certificate-file = config.sops.secrets."gatus/mtls-cert".path;
        tls.private-key-file = config.sops.secrets."gatus/mtls-key".path;
      };

      endpoints =
        map (endpoint: (defaults // endpoint) // (alertDefaults (endpoint.alerts.description or null))) [
          {
            name = "Forgejo";
            url = "https://git.theless.one";
            alerts.description =
              "This is our code forge and it's crucial for the entire server infrastructure.\n"
              + "It deals with automatic updates of the Server and automations for deploying changes "
              + "to the Server.\n"
              + notify;
          }
          {
            name = "Vaultwarden";
            url = "https://vaultwarden.theless.one";
            alerts.description =
              "Our own server for the password manager Bitwarden. "
              + "Some of us use this as our primary and only password manager.\n"
              + "We don't have a fallover server at this point in time which is why "
              + "it's pretty crucial to keep this running.\n"
              + notify;
          }
          {
            name = "Copyparty";
            url = "https://files.theless.one";
          }
          {
            name = "Immich";
            url = "https://immich.theless.one";
            alerts.description =
              "An image backup service like Google Photos.\n"
              + "Usually it isn't that crucial to have this up all the time "
              + "since photos are mostly also stored on the local devices.";
          }
          {
            name = "Fireshare";
            url = "https://fireshare.theless.one";
            alerts.description = "A clip sharing server.";
          }
        ]
        ++ map arrDefaults arrServices;
    };
  };

  config'.caddy.vHost."https://status.nanoyaki.space".proxy = {
    inherit (config.services.gatus.settings.web) port;
  };
}
