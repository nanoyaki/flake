{ self, config, ... }:

{
  imports = [
    self.nixosModules.gluetun
  ];

  sec."gluetun/environment" = { };

  services.gluetun = {
    enable = false;
    environment = {
      VPN_SERVICE_PROVIDER = "protonvpn";
      VPN_TYPE = "wireguard";
      VPN_INTERFACE = "tun0";
      SERVER_COUNTRIES = "Netherlands";
    };
    environmentFile = config.sec."gluetun/environment".path;
  };
}
