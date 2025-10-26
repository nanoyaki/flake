{
  config,
  ...
}:

{
  sops.secrets.wg0 = { };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.101.0.1/24"
      "fd10::1/64"
    ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.wg0.path;

    peers = [
      {
        publicKey = "95xHXn8LjJ3wR7pSPDIyH2j7VGu38egMPJYJoWSgQDw=";
        allowedIPs = [
          "10.101.0.2/32"
          "fd10::2/128"
        ];
      }
      {
        publicKey = "Vaq/AzMYsYq0Ba1MS75uyqTJuYk+L5jHUv67ms3jdgQ=";
        allowedIPs = [
          "10.101.0.3/32"
          "fd10::3/128"
        ];
      }
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enu1u1u1";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall = {
    trustedInterfaces = [ "wg0" ];
    allowedUDPPorts = [ 51820 ];
  };
}
