{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.networking ];

    networking.hostId = "bfff451b";
    networking.networkmanager.enable = true;
  };

  configurations.nixos.kanokoyuri = _: {
    imports = [ config.modules.nixos.networking ];

    networking.hostId = "69804090";
    networking.useDHCP = false;

    networking.interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.9";
          prefixLength = 24;
        }
      ];

      ipv6.addresses = [
        {
          address = "fd17:a170:7ac1::3";
          prefixLength = 64;
        }
      ];
    };

    networking.defaultGateway = {
      address = "10.0.0.1";
      interface = "enp1s0";
    };

    networking.defaultGateway6 = {
      address = "fd17:a170:7ac1:0:6b4:feff:fe7f:c3ef";
      interface = "enp1s0";
    };
  };

  modules.nixos.networking =
    { lib, ... }:

    let
      inherit (lib) mkDefault;
    in

    {
      networking = {
        nftables.enable = true;
        firewall.enable = true;

        enableIPv6 = true;
        useDHCP = mkDefault true;
        networkmanager.enable = mkDefault false;

        nameservers = mkDefault [
          "9.9.9.9"
          "2620:fe::fe"
          "149.112.112.112"
          "2620:fe::9"
          "1.1.1.1"
          "2606:4700:4700::1111"
          "1.0.0.1"
          "2606:4700:4700::1001"
        ];
      };
    };
}
