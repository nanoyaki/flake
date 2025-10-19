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
      "10.100.0.2/32"
      "fd50::2/128"
    ];
    privateKeyFile = config.sops.secrets.wg0.path;
    dns = [ "10.100.0.1" ];

    postUp = ''
      ${iptables} -A FORWARD -i wg0 -j ACCEPT
      ${iptables} -t nat -A POSTROUTING -s 10.100.0.1/24 -o enp5s0 -j MASQUERADE

      ${ip6tables} -A FORWARD -i wg0 -j ACCEPT
      ${ip6tables} -t nat -A POSTROUTING -s fd50::1/64 -o enp5s0 -j MASQUERADE
    '';

    preDown = ''
      ${iptables} -D FORWARD -i wg0 -j ACCEPT
      ${iptables} -t nat -D POSTROUTING -s 10.100.0.1/24 -o enp5s0 -j MASQUERADE

      ${ip6tables} -D FORWARD -i wg0 -j ACCEPT
      ${ip6tables} -t nat -D POSTROUTING -s fd50::1/64 -o enp5s0 -j MASQUERADE
    '';

    peers = [
      {
        publicKey = "8yqbMtP4OzQOfpxI6KU41900p+rGmwBZ83KM/scj/0s=";
        endpoint = "nanoyaki.space:51820";
        allowedIPs = [
          "10.100.0.1/24"
          "fd50::1/64"
        ];
        persistentKeepalive = 25;
      }
    ];
  };

  networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enp5s0";
    internalInterfaces = [ "wg0" ];
  };
}
