{
  flake.nixosModules.kuroyuri-networking =
    { config, ... }:

    {
      sops.secrets.pikvm0 = { };

      services.tailscale.enable = true;

      networking = {
        hostId = "4433d464";
        hostName = "kuroyuri";
        networkmanager.enable = true;
        useDHCP = false;
      };

      networking.wireguard.interfaces.pikvm0 = {
        ips = [ "10.200.200.2/32" ];
        privateKeyFile = config.sops.secrets.pikvm0.path;

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
