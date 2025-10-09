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

  config'.caddy.vHost."https://immich.nanoyaki.space".extraConfig = ''
    @not-vpn not remote_ip 10.100.0.0/24
    respond @not-vpn "Forbidden" 403
  '';

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
