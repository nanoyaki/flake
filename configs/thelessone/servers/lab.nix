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

  systemd.services."systemd-tmpfiles-resetup" = {
    requires = [ "network-online.target" ];
    after = [ "mnt-raid.mount" ];
  };

  sec."vaultwarden".owner = "vaultwarden";

  services.vaultwarden = {
    config = {
      SMTP_HOST = "smtp.gmail.com";
      SMTP_PORT = 587;
      SMTP_SECURITY = "starttls";

      SMTP_FROM = "hanakretzer+vaultwarden@gmail.com";
      SMTP_FROM_NAME = "${config.services'.caddy.baseDomain} Vaultwarden Server";

      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      REQUIRE_DEVICE_EMAIL = true;

      ORG_CREATION_USERS = "hanakretzer@gmail.com";
    };

    environmentFile = config.sec."vaultwarden".path;
  };

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
    whisparr.subdomain = "whisparr.vpn";
    whisparr.homepage.enable = true;

    paperless.enable = false;
    home-assistant.enable = false;

    caddy = {
      baseDomain = "theless.one";

      reverseProxies =
        (mapAttrs' (
          service: _: nameValuePair (domain config.services'.${service}) { vpnOnly = true; }
        ) privateServices)
        // {
          "https://vpn.theless.one".vpnOnly = true;
        };
    };

    homepage = {
      useSubdomain = true;
      subdomain = "vpn";

      categories = {
        Media.before = "Services";
        Services.before = "Code";
      };

      glances.layout.columns = 3;
      glances.widgets = [
        { "CPU usage".metric = "cpu"; }
        { "Memory usage".metric = "memory"; }
        { "Network usage".metric = "network:enp6s0"; }
        { "VPN Network usage".metric = "network:tailscale0"; }
        { "Storage usage NVMe".metric = "fs:/"; }
        { "Disk I/O NVMe".metric = "disk:nvme0n1"; }
      ];
    };
  };
}
