{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "home.lan";

    settings = {
      title = "Homepage";
      startUrl = "http://home.lan";
      theme = "dark";
      language = "de";
      logpath = "/var/log/homepage/homepage.log";
      disableUpdateCheck = true;
      target = "_blank";
    };

    services = [
      {
        "Smart Home" = [
          {
            "Homeassistant" = {
              description = "Smart home Geräte-Platform";
              href = "https://homeassistant.home.lan";
            };
          }
        ];
      }
    ];

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        search.provider = "google";
      }
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

  systemd.tmpfiles.settings."10-homepage"."/var/log/homepage".d = {
    user = "root";
    group = "wheel";
    mode = "0755";
  };
}
