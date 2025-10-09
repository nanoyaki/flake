{ config, ... }:

{
  sops.secrets.wg0 = { };

  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.100.0.2/32" ];
    privateKeyFile = config.sops.secrets.wg0.path;
    dns = [ "10.100.0.1" ];

    peers = [
      {
        publicKey = "8yqbMtP4OzQOfpxI6KU41900p+rGmwBZ83KM/scj/0s=";
        endpoint = "nanoyaki.space:51820";
        allowedIPs = [ "10.100.0.1/24" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
