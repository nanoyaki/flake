{ lib, config, ... }:

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "4000";
    };
  };

  services'.caddy.reverseProxies."https://status.nanoyaki.space".port =
    lib.strings.toInt config.services.uptime-kuma.settings.PORT;
}
