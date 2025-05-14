{ lib, config, ... }:

{
  sec.wireguard = { };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.2/32" ];
    listenPort = 51820;

    privateKeyFile = config.sec.wireguard.path;
    peers = lib.singleton {
      publicKey = "SP7OFdgX2NxOkMYrn5avW+i20r7wKo0aBqCgD/wNsUI=";
      allowedIPs = [
        "10.100.0.2/32"
        "10.100.0.1/32"
        "192.168.178.84/32"
      ];
      name = "thelessone";
      endpoint = "theless.one:51820";
      persistentKeepalive = 30;
    };
  };
}
