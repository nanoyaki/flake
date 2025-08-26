{
  networking = {
    interfaces.enp6s0 = {
      ipv6.addresses = [
        {
          address = "2001:4bb8:1ce:e329::2";
          prefixLength = 64;
        }
        {
          address = "fd6f:9046:1f17::2";
          prefixLength = 64;
        }
      ];
      ipv4.addresses = [
        {
          address = "10.0.0.5";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "10.0.0.1";
      interface = "enp6s0";
    };
    defaultGateway6 = {
      address = "fe80::6b4:feff:fe15:19e5";
      interface = "enp6s0";
    };
  };
}
