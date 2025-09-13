{ config, ... }:

{
  config'.immich.enable = true;

  services.immich-public-proxy = {
    enable = true;
    immichUrl = "http://localhost:2283";
    port = 19220;
    settings.allowDownloadAll = 1;
  };

  config'.caddy.vHost."images.theless.one".proxy = {
    inherit (config.services.immich-public-proxy) port;
  };
}
