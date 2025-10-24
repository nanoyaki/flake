{
  services.caddy = {
    enable = true;
    email = "contact@nanoyaki.space";

    extraConfig = ''
      (tls) {
        tls /var/lib/acme/hanakretzer.de/cert.pem /var/lib/acme/hanakretzer.de/key.pem
      }
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
