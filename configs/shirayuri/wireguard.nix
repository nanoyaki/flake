{
  config,
  ...
}:

{
  sops.secrets = {
    wg0 = { };
    wg1 = { };
    wg2 = { };
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = [
        "10.101.0.2/32"
        "fd10::2/128"
      ];
      privateKeyFile = config.sops.secrets.wg0.path;

      peers = [
        {
          publicKey = "kdBOsYomUk9YEFs+qSsKHnbaMAL6r57IlkJoNweRKj8=";
          endpoint = "hanakretzer.de:51820";
          allowedIPs = [
            "10.101.0.1/32"
            "fd10::1/128"
          ];
          persistentKeepalive = 25;
        }
      ];
    };

    wg1 = {
      address = [
        "100.64.64.7/32"
        "fd64::7/128"
      ];
      privateKeyFile = config.sops.secrets.wg1.path;

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

    wg2 = {
      address = [ "10.200.200.2/32" ];
      privateKeyFile = config.sops.secrets.wg2.path;

      peers = [
        {
          publicKey = "Pd934yDpHcc2pdv4eV2YBQYGgncW/yacNHtoNQsA5wM=";
          endpoint = "theless.one:51821";
          allowedIPs = [ "10.200.200.1/32" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
