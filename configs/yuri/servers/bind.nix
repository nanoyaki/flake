{ pkgs, ... }:

let
  networks = [
    "127.0.0.0/24"
    "::1/128"
    "10.0.0.0/24"
    "100.64.0.0/10"
  ];
in

{
  services.bind = {
    enable = true;

    cacheNetworks = networks;
    zones."home.lan" = {
      master = true;
      allowQuery = networks;
      file = pkgs.writeText "zone-home.lan" ''
        $TTL 3600
        @  IN  SOA  ns1.home.lan. admin.home.lan. (
                2025050101 ; Serial number
                3600       ; Refresh
                1800       ; Retry
                604800     ; Expire
                3600       ; Minimum TTL
        )

        ; Name Server for the zone
        @  IN  NS   ns1.home.lan.

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

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
