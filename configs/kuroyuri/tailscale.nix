{ config, ... }:

{
  sec."tailscale" = { };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    authKeyFile = config.sec."tailscale".path;
  };
}
