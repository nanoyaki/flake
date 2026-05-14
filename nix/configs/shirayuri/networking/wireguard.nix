{
  flake.nixosModules.shirayuri-wireguard =
    { pkgs, config, ... }:

    {
      sops.secrets = {
        wg0 = { };
        wg2 = { };
      };

      environment.systemPackages = [ pkgs.pangolin-cli ];

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

        wg2 = {
          address = [ "10.200.200.2/32" ];
          privateKeyFile = config.sops.secrets.wg2.path;

          peers = [
            {
              publicKey = "Pd934yDpHcc2pdv4eV2YBQYGgncW/yacNHtoNQsA5wM=";
              endpoint = "at01.theless.one:51821";
              allowedIPs = [ "10.200.200.1/32" ];
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
}
