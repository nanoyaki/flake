{ config, ... }:

{
  systemd.services.jellyfin.restartTriggers = [ config.hardware.nvidia.package ];

  config'.jellyfin.enable = true;
}
