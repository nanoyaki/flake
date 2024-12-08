{
  networking.nftables.enable = true;
  networking.firewall.enable = true;

  # Allowed TCP ports
  networking.firewall.allowedTCPPorts = [
    # HTTP(S)
    80
    443

    # SCP query
    7777
  ];

  # TCP port ranges
  networking.firewall.allowedTCPPortRanges = [

  ];

  # Allowed UDP Ports
  networking.firewall.allowedUDPPorts = [
    # SCP
    7777
  ];

  # UDP port ranges
  networking.firewall.allowedUDPPortRanges = [

  ];
}
