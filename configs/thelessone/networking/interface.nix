{
  networking = {
    useDHCP = true;

    interfaces.enp6s0 = {
      useDHCP = true;
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
  };
}
