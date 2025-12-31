{ config, ... }:

{
  sops.secrets.wg0 = { };

  networking.wg-quick.interfaces.wg0 = {
    address = [
      "100.64.64.22/32"
      "fd64::22/128"
    ];
    privateKeyFile = config.sops.secrets.wg0.path;

    peers = [
      {
        publicKey = "JB0jviICHpiTm1PYjm4+FCWCPLAjU/NZBm6tRO6/XGY=";
        endpoint = "theless.one:51820";
        allowedIPs = [
          "100.64.64.1/32"
          "fd64::1/128"
        ];
        persistentKeepalive = 25;
      }
    ];
  };
}
