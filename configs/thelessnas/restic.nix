{ config, ... }:

{
  sops.secrets.restic.owner = "restic";

  networking.firewall.interfaces.enp6s0.allowedTCPPorts = [ 8000 ];

  services.restic.server = {
    enable = true;
    dataDir = "/moon/restic";
    htpasswd-file = config.sops.secrets.restic.path;
  };

  systemd.services.restic-rest-server = {
    after = [ "zfs-import-moon.service" ];
    requires = [ "zfs-import-moon.service" ];
  };
}
