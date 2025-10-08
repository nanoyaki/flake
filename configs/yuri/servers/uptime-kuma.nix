{
  lib,
  config,
  ...
}:

{
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "4000";
    };
  };

  config'.caddy.vHost."https://status.nanoyaki.space".proxy.port =
    lib.strings.toInt config.services.uptime-kuma.settings.PORT;
}
