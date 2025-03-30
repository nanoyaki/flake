{ config, ... }:

{
  sec."tailscale" = { };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    authKeyFile = config.sec."tailscale".path;
  };
}
