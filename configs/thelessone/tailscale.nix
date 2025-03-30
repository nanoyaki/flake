{ config, ... }:

{
  sec."tailscale" = { };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    authKeyFile = config.sec."tailscale".path;
  };
}
