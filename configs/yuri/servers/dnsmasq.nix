{
  networking.resolvconf.useLocalResolver = true;

  services.dnsmasq = {
    enable = true;
    settings = {
      listen-address = [
        "127.0.0.1"
        "10.0.0.3"
        "10.100.0.1"
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
      ];
      cache-size = 1000;
      dhcp-lease-max = 300;
    };
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];
}
