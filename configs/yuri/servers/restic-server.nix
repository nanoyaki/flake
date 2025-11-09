{ config, ... }:

{
  sops.secrets.restic-server.owner = "restic";

  networking.firewall.interfaces.wg1.allowedTCPPorts = [ 8000 ];
  networking.firewall.interfaces.enp7s0.allowedTCPPorts = [ 8000 ];

  services.restic.server = {
    enable = true;
    dataDir = "/mnt/nvme-raid-1/var/lib/restic";
    htpasswd-file = config.sops.secrets.restic-server.path;
  };
}
