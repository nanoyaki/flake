{
  flake.nixosModules.shirayuri-wireguard =
    { config, ... }:

    {
      sops.secrets.wg2 = { };

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
      };

      networking.wg-quick.interfaces.wg2 = {
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
}
