{ lib, config, ... }:

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "4000";
    };
  };

  services.homepage-easify.categories.Services.services."Uptime Kuma" = rec {
    description = "Monitoring tool";
    icon = "uptime-kuma.svg";
    href = "https://uptimekuma.theless.one";
    siteMonitor = href;
  };

  services.caddy-easify.reverseProxies."uptimekuma.theless.one".port =
    lib.strings.toInt config.services.uptime-kuma.settings.PORT;
}
