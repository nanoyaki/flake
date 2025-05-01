{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;

    settings = {
      title = "Homepage";
      startUrl = "https://home.lan";
      theme = "dark";
      language = "de";
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
}
