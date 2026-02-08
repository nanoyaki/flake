{
  flake.nixosModules.networking =
    { lib, ... }:

    {
      networking = {
        nftables.enable = true;
        firewall.enable = true;

        useDHCP = lib.mkDefault true;
        networkmanager.enable = lib.mkDefault false;

        nameservers = lib.mkDefault [
          "1.1.1.1"
          "1.0.0.1"
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
    };
}
