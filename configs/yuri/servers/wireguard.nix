{
  lib,
  pkgs,
  config,
  ...
}:

let
  iptables = lib.getExe' pkgs.iptables "iptables";
  ip6tables = lib.getExe' pkgs.iptables "ip6tables";
in

{
  sops.secrets.wg0 = { };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "10.100.0.1/24"
      "fd50::1/64"
    ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets.wg0.path;

    postUp = ''
      ${iptables} -A FORWARD -i wg0 -j ACCEPT
      ${iptables} -t nat -A POSTROUTING -s 10.100.0.1/24 -o enp7s0 -j MASQUERADE

      ${ip6tables} -A FORWARD -i wg0 -j ACCEPT
      ${ip6tables} -t nat -A POSTROUTING -s fd50::1/64 -o enp7s0 -j MASQUERADE
    '';

    preDown = ''
      ${iptables} -D FORWARD -i wg0 -j ACCEPT
      ${iptables} -t nat -D POSTROUTING -s 10.100.0.1/24 -o enp7s0 -j MASQUERADE

      ${ip6tables} -D FORWARD -i wg0 -j ACCEPT
      ${ip6tables} -t nat -D POSTROUTING -s fd50::1/64 -o enp7s0 -j MASQUERADE
    '';

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

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enp7s0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
}
