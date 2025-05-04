{ pkgs, ... }:

let
  networks = [
    "127.0.0.0/24"
    "::1/128"
    "10.0.0.0/24"
    "fe80::/10"
  ];
in

{
  networking.resolvconf.useLocalResolver = true;

  services.bind = {
    enable = true;

    cacheNetworks = networks;
    zones."home.local" = {
      master = true;
      allowQuery = networks;
      file = pkgs.writeText "zone-home.local" ''
        $TTL 1h
        @  IN  SOA  ns1.home.local. admin.home.local. (
                2025050402 ; Serial number
                3h         ; Refresh
                1h         ; Retry
                1w         ; Expire
                1h         ; Minimum TTL
        )

        ; Name Server for the zone
        @  IN  NS   ns1.home.local.

        ; Records
        @  IN  A    10.0.0.3
        *  IN  A    10.0.0.3
      '';
    };

    forwarders = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  services.resolved.enable = false;

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  systemd.services.bind.serviceConfig.Nice = "-20";

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
