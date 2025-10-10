{ config, ... }:

{
  services.immich.mediaLocation = "/mnt/nvme-raid-1/var/lib/immich";

  config'.immich = {
    enable = true;
    homepage = {
      category = "Medien";
      description = "Foto backup software";
    };
  };

  config'.caddy.vHost."https://immich.nanoyaki.space".enable = false;
  config'.caddy.vHost."immich.nanoyaki.space" = {
    proxy = {
      inherit (config.services.immich) port;
      host = "127.0.0.1";
    };
    extraConfig = ''
      @web not client_ip private_ranges 10.100.0.0/24 10.0.0.0/24
      respond @web "Forbidden" 403
    '';
  };

  config'.caddy.vHost."http://immich.home.local".proxy = {
    inherit (config.services.immich) port;
    host = "127.0.0.1";
  };

  services.immich-public-proxy = {
    enable = true;
    immichUrl = "http://localhost:${toString config.services.immich.port}";
    port = 19220;
    settings.allowDownloadAll = 1;
  };

  config'.caddy.vHost."images.nanoyaki.space".proxy = {
    inherit (config.services.immich-public-proxy) port;
  };
}
