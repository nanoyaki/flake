{ config, ... }:

{
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "home.local";

    settings = {
      title = "Homepage";
      startUrl = "http://home.local";
      theme = "dark";
      language = "de";
      logpath = "/var/log/homepage/homepage.log";
      disableUpdateCheck = true;
      target = "_blank";

      layout.Glances = {
        header = false;
        style = "column";
      };
    };

    services = [
      {
        Glances =
          let
            url = "http://localhost:${toString config.services.glances.port}";
          in
          [
            {
              Info.widget = {
                inherit url;
                type = "glances";
                metric = "info";
                chart = false;
                version = 4;
              };
            }
            {
              Speicherplatz.widget = {
                inherit url;
                type = "glances";
                metric = "fs:/";
                chart = false;
                version = 4;
              };
            }
            {
              "CPU Temp".widget = {
                inherit url;
                type = "glances";
                metric = "sensor:Package id 0";
                version = 4;
              };
            }
            {
              Netzwerk.widget = {
                inherit url;
                type = "glances";
                metric = "network:enp3s0";
                version = 4;
              };
            }
          ];
      }
      {
        "Smart Home" = [
          {
            Homeassistant = {
              description = "Smart home Geräte-Platform";
              href = "https://homeassistant.home.local";
            };
          }
        ];
      }
    ];

    widgets = [
      {
        openmeteo = {
          label = "Haiger";
          latitude = "50.7722007";
          longitude = "8.1304181";
          timezone = "Europe/Berlin";
          units = "metric";
          cache = 5;
          format.maximumFractionDigits = 1;
        };
      }
    ];
  };

  services.glances.enable = true;

  systemd.tmpfiles.settings."10-homepage"."/var/log/homepage".d = {
    user = "root";
    group = "wheel";
    mode = "0755";
  };
}
