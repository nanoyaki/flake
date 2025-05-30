{ config, ... }:

{
  sec."restic-server".owner = "restic";

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8000 ];

  services.restic.server = {
    enable = true;
    dataDir = "/mnt/nvme-raid-1/var/lib/restic";
    htpasswd-file = config.sec."restic-server".path;
  };
}
