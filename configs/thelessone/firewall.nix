{
  networking = {
    nftables.enable = true;

    firewall = {
      enable = true;

      # Allowed TCP ports
      allowedTCPPorts = [
        # HTTP(S)
        80
        443

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
