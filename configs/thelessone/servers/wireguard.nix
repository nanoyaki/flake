{
  lib,
  pkgs,
  config,
  ...
}:

let
  clientPubKeys = [
    "6fs+if9+ojFMlkelk4yoENjMfDi/ERt2KreRyfINxTM="
    "l6z2NGlhXmtwofkfusUOukQD7Z9Y3CUVtfyalOD4RRY="
    "wzC2j9CI07ciQkBMdDEwtjMCTl7OXTR7wZwIxE7diWg="
    "SBqbL+2sDiJMs56wBp8xuKDOXZbctNjFMi/EvbNgQks="
    "mQSObDprEiHjsYOnrQ5gLYHTdpH8+NdD3NbDFzfNliI="
    "Lo2KLmBatmeRgbyNxEU0rg0gqijd5t4ukb9TXkfflmI="
    "Zg6GSPgPCoBr8GtEjLtMS0HoWbxssH9OZPfXAogCzHE="
    "S480Mz8BCnBvwgYNezjA5Pj6RTQ+4bkloaR3N693NUM="
    "o6fDW0XZY45jDdCNiBnYLntzN457NHBE6ZXXs4BSIk8="
  ];

  networks = [
    "127.0.0.0/8"
    "::1/128"
    "192.168.178.0/24"
    "fe80::/10"
    "10.100.0.0/24"
    "fdc9:281f:04d7:9ee9::/124"
  ];

  nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];
in

{
  sec.wireguard = { };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [
      53
      51820
    ];
    trustedInterfaces = [ "wg0" ];
  };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.100.0.1/28"
      "fdc9:281f:04d7:9ee9::1/124"
    ];
    dns = [
      "10.100.0.1"
      "fdc9:281f:04d7:9ee9::1"
    ];
    listenPort = 51820;
    privateKeyFile = config.sec.wireguard.path;

    peers = lib.map (
      publicKey:
      let
        device = (lib.lists.findFirstIndex (self: publicKey == self) 0 clientPubKeys) + 2;
      in
      {
        inherit publicKey;
        allowedIPs = [
          "10.100.0.${toString device}/32"
          "fdc9:281f:04d7:9ee9::${lib.toHexString device}/128"
        ];
        persistentKeepalive = 25;
      }
    ) clientPubKeys;
  };

  services.resolved.enable = false;
  networking.resolvconf.useLocalResolver = true;
  services.bind = {
    enable = true;

    cacheNetworks = networks;
    zones."theless.one" = {
      master = true;
      allowQuery = networks;
      file = pkgs.writeText "zone-theless.one" ''
        $TTL 1h
        @  IN  SOA  ns1.theless.one. admin.theless.one. (
                2025051401 ; Serial number
                3h         ; Refresh
                1h         ; Retry
                1w         ; Expire
                1h         ; Minimum TTL
        )

        ; Name Server for the zone
        @  IN  NS   ns1.theless.one.

        ; Records
        @  IN  A    10.100.0.1
        *  IN  A    10.100.0.1
      '';
    };

    forwarders = nameservers;
  };
}
