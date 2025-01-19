{
  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;

      # Allowed TCP ports
      allowedTCPPorts = [
        # SCP query
        # 7777
      ];

      # TCP port ranges
      allowedTCPPortRanges = [

      ];

      # Allowed UDP Ports
      allowedUDPPorts = [
        # SCP
        # 7777
      ];

      # UDP port ranges
      allowedUDPPortRanges = [

      ];
    };
  };
}
