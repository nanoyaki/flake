{ lib, config, ... }:

let
  cfg = config.services.dnsmasq;
in

{
  networking.resolvconf.useLocalResolver = true;

  services.dnsmasq = {
    enable = true;
    settings = {
      listen-address = [
        "127.0.0.1"
        "::1"
        "10.0.0.3"
        "10.100.0.1"
        "fd50::1"
      ];

      server = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "8.8.4.4"
      ];

      address = [
        "/nanoyaki.space/10.100.0.1"
        "/.nanoyaki.space/10.100.0.1"
        "/nanoyaki.space/fd50::1"
        "/.nanoyaki.space/fd50::1"
        "/home.local/10.0.0.3"
        "/.home.local/10.0.0.3"
      ];

      cache-size = 10000;
    };
  };

  systemd.services.dnsmasq.serviceConfig.ExecStart =
    lib.mkForce "${cfg.package}/bin/dnsmasq -k --enable-dbus --user=dnsmasq -C ${cfg.configFile} -0 1000";

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
}
