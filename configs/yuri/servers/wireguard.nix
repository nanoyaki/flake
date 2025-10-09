{ config, ... }:

{
  sops.secrets.wg0 = { };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.100.0.1/24"
      "fd50::1/64"
    ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.wg0.path;

    peers = [
      {
        publicKey = "6GlVmj7IjMdMU/Dyf7Q3mbsYmLr6T8Qak7uAEMQx73c=";
        allowedIPs = [
          "10.100.0.2/32"
          "fd50::2/128"
        ];
      }
      {
        publicKey = "8yqbMtP4OzQOfpxI6KU41900p+rGmwBZ83KM/scj/0s=";
        allowedIPs = [
          "10.100.0.3/32"
          "fd50::3/128"
        ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
}
