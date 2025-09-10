{ config, ... }:

{
  config'.immich.enable = true;

  services.immich-public-proxy = {
    enable = true;
    immichUrl = "https://immich.theless.one";
    port = 19220;
    settings.allowDownloadAll = 1;
  };

  config'.caddy.reverseProxies."https://images.theless.one" = {
    inherit (config.services.immich-public-proxy) port;
  };
}
