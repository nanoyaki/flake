{ config, ... }:

{
  sops.secrets.restic-server.owner = "restic";

  services.restic.server = {
    enable = true;
    listenAddress = "127.0.0.1:8001";
    htpasswd-file = config.sops.secrets.restic-server.path;
  };

  services.caddy.virtualHosts."restic.hanakretzer.de" = {
    listenAddresses = [
      "100.64.64.6"
      "fd64::6"
    ];

    useACMEHost = "hanakretzer.de";
    extraConfig = ''
      reverse_proxy ${config.services.restic.server.listenAddress}
    '';
  };
}
