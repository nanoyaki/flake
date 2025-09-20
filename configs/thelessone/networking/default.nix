{
  imports = [
    ./deployment.nix
    ./fireqos.nix
    ./firewall.nix
    ./interface.nix
  ];

  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "both";
  };
}
