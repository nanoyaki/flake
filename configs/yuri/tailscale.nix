{ config, ... }:

{
  sec."tailscale" = { };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--reset" ];
    authKeyFile = config.sec."tailscale".path;
  };
}
