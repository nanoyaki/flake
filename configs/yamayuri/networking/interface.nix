{
  networking = {
    interfaces.enu1u1u1 = {
      useDHCP = false;

      ipv6.addresses = [
        {
          address = "2a00:10:946:bf01::2";
          prefixLength = 64;
        }
        {
          address = "fd11:ad5:2cc6::2";
          prefixLength = 64;
        }
      ];

      ipv4.addresses = [
        {
          address = "10.0.0.101";
          prefixLength = 8;
        }
      ];
    };

    defaultGateway = {
      address = "10.0.0.1";
      interface = "enu1u1u1";
    };
    defaultGateway6 = {
      address = "fe80::1eed:6fff:fe2c:bfc9";
      interface = "enu1u1u1";
    };

    nameservers = [
      "10.0.0.1"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
