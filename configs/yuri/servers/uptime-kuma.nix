{ lib, config, ... }:

{
  sec."dynamicdns/theless.one" = { };

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "4000";
    };
  };

  services'.caddy.reverseProxies."status.theless.one".port =
    lib.strings.toInt config.services.uptime-kuma.settings.PORT;

  services'.dynamicdns.domains."theless.one" = {
    subdomains = [ "status" ];
    passwordFile = config.sec."dynamicdns/theless.one".path;
  };
}
