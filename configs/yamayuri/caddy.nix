{
  services.caddy = {
    enable = true;
    email = "contact@nanoyaki.space";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
