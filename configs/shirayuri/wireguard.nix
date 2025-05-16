{ config, ... }:

{
  sec.wireguard = { };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.100.0.2/24"
      "fdc9:281f:04d7:9ee9::2/124"
    ];
    dns = [
      "10.100.0.1"
      "fdc9:281f:04d7:9ee9::1"
    ];
    listenPort = 51820;

    privateKeyFile = config.sec.wireguard.path;
    peers = [
      {
        publicKey = "SP7OFdgX2NxOkMYrn5avW+i20r7wKo0aBqCgD/wNsUI=";
        allowedIPs = [
          "10.100.0.0/24"
          "fdc9:281f:04d7:9ee9::/124"
        ];
        endpoint = "theless.one:51820";
        persistentKeepalive = 25;
      }
    ];
  };
}
