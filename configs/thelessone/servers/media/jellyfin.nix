{ config, ... }:

{
  systemd.services.jellyfin.restartTriggers = [ config.hardware.nvidia.package ];

  config'.jellyfin = {
    enable = true;
    subdomain = "jellyfin.vpn";
  };

  systemd.services.jellyfin.unitConfig.RequiresMountsFor = [ "/mnt/raid" ];
}
