{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "home.lan";

    settings = {
      title = "Homepage";
      startUrl = "http://home.lan";
      base = "http://home.lan";
      theme = "dark";
      language = "de";
      logpath = "/var/log/homepage/homepage.log";
      disableUpdateCheck = true;
      target = "_blank";
    };

    services = [
      {
        "Smart Home" = {
          "Homeassistant" = {
            description = "Smart home Geräte-Platform";
            href = "https://homeassistant.home.lan";
          };
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
