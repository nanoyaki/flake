{ config, ... }:

{
  systemd.services.jellyfin.restartTriggers = [ config.hardware.nvidia.package ];

  config'.jellyfin.enable = true;

  config'.caddy.vHost."jellyfin.vpn.theless.one" = {
    vpnOnly = true;
    proxy.port = 8096;
  };
}
