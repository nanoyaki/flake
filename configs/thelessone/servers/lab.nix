{
  self,
  lib,
  config,
  ...
}:

let
  inherit (lib) nameValuePair mapAttrs' filterAttrs;

  inherit (config.services'.caddy._helpers { cfg = config.services'.caddy; }) domain;

  excludes = [
    "uptimekuma"
    "immich"
    "vaultwarden"
    "homepage-images"
    "homepage"
  ];

  privateServices = filterAttrs (
    name: cfg: cfg.enable && !(lib.elem name excludes) && cfg ? subdomain
  ) config.services';
in

{
  imports = [
    self.nixosModules.lab-config
  ];

  services' = {
    lab-config.arr.home = "/mnt/raid/arr-stack";

    bazarr.subdomain = "bazarr.vpn";
    jellyfin.subdomain = "jellyfin.vpn";
    jellyseerr.subdomain = "jellyseerr.vpn";
    lidarr.subdomain = "lidarr.vpn";
    prowlarr.subdomain = "prowlarr.vpn";
    radarr.subdomain = "radarr.vpn";
    sabnzbd.subdomain = "sabnzbd.vpn";
    sonarr.subdomain = "sonarr.vpn";
    transmission.subdomain = "transmission.vpn";
    immich.subdomain = "immich.vpn";

    paperless.enable = false;
    home-assistant.enable = false;

    caddy.baseDomain = "theless.one";
    caddy.reverseProxies =
      (mapAttrs' (
        service: _: nameValuePair (domain config.services'.${service}) { vpnOnly = true; }
      ) privateServices)
      // {
        "https://vpn.theless.one".vpnOnly = true;
      };

    homepage = {
      useSubdomain = true;
      subdomain = "vpn";

      categories = {
        Media.before = "Services";
        Services.before = "Code";
      };

      glances.layout.columns = 4;
      glances.widgets = [
        {
          "CPU usage" = {
            metric = "cpu";
            chart = true;
          };
        }
        {
          "Memory usage" = {
            metric = "memory";
            chart = true;
          };
        }
        {
          "Network usage" = {
            metric = "network:enp6s0";
            chart = true;
          };
        }
        {
          "VPN Network usage" = {
            metric = "network:tailscale0";
            chart = true;
          };
        }
        {
          "Storage usage RAID" = {
            metric = "fs:/mnt/raid";
            chart = true;
          };
        }
        {
          "Disk I/O RAID" = {
            metric = "disk:sda";
            chart = true;
          };
        }
        {
          "Storage usage NVMe" = {
            metric = "fs:/";
            chart = true;
          };
        }
        {
          "Disk I/O NVMe" = {
            metric = "disk:nvme0n1";
            chart = true;
          };
        }
      ];
    };
  };
}
