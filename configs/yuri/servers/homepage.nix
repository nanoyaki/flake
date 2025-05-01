{ config, ... }:

let
  mkGlancesWidget = name: metric: {
    ${name}.widget = {
      url = "http://localhost:${toString config.services.glances.port}";
      type = "glances";
      chart = false;
      version = 4;
      inherit metric;
    };
  };
in

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
        style = "row";
      };

      headerStyle = "clean";
      statusStyle = "dot";
      hideVersion = "true";
    };

    services = [
      {
        Glances = [
          (mkGlancesWidget "Info" "info")
          (mkGlancesWidget "Speicherplatz" "fs:/")
          (mkGlancesWidget "CPU Temp" "sensor:Package id 0")
          (mkGlancesWidget "Netzwerk" "network:enp3s0")
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
  };

  services.glances.enable = true;

  systemd.tmpfiles.settings."10-homepage"."/var/log/homepage".d = {
    user = "root";
    group = "wheel";
    mode = "0755";
  };
}
