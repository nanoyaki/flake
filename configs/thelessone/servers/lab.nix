# This code sucks, i'll change it whenever i feel like it
{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib)
    nameValuePair
    mapAttrs'
    filterAttrs
    genAttrs
    ;

  excludes = [
    "uptimekuma"
    "immich"
    "vaultwarden"
    "homepage-images"
    "homepage"
  ];

  privateServices = filterAttrs (
    name: cfg: cfg ? enable && cfg.enable && !(lib.elem name excludes) && cfg ? subdomain
  ) config.config';
in

{
  systemd.services =
    genAttrs
      [
        "systemd-tmpfiles-clean"
        "systemd-tmpfiles-setup"
        "systemd-tmpfiles-setup-dev"
        "systemd-tmpfiles-setup-dev-early"
        "systemd-tmpfiles-resetup"
      ]
      (_: {
        requires = [ "mnt-raid.mount" ];
        after = [ "mnt-raid.mount" ];
      });

  sops.secrets.vaultwarden-smtp-password.owner = "vaultwarden";
  sops.templates."vaultwarden.env".file = (pkgs.formats.keyValue { }).generate "vaultwarden.env" {
    SMTP_PASSWORD = config.sops.placeholder.vaultwarden-smtp-password;
  };

  services.vaultwarden = {
    config = {
      SMTP_HOST = "smtp.gmail.com";
      SMTP_PORT = 587;
      SMTP_SECURITY = "starttls";

      SMTP_USERNAME = "hanakretzer@gmail.com";
      SMTP_FROM = "hanakretzer+vaultwarden@gmail.com";
      SMTP_FROM_NAME = "${config.config'.caddy.baseDomain} Vaultwarden Server";

      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = true;
      REQUIRE_DEVICE_EMAIL = true;

      ORG_CREATION_USERS = "hanakretzer@gmail.com";
    };

    environmentFile = config.sops.templates."vaultwarden.env".path;
  };

  config' = {
    lab-config.enable = true;
    lab-config.arr.home = "/mnt/raid/arr-stack";

    bazarr.enable = true;
    bazarr.subdomain = "bazarr.vpn";
    jellyfin.enable = true;
    jellyfin.subdomain = "jellyfin.vpn";
    jellyseerr.enable = true;
    jellyseerr.subdomain = "jellyseerr.vpn";
    lidarr.enable = true;
    lidarr.subdomain = "lidarr.vpn";
    prowlarr.enable = true;
    prowlarr.subdomain = "prowlarr.vpn";
    radarr.enable = true;
    radarr.subdomain = "radarr.vpn";
    sabnzbd.enable = true;
    sabnzbd.subdomain = "sabnzbd.vpn";
    sonarr.enable = true;
    sonarr.subdomain = "sonarr.vpn";
    transmission.enable = true;
    transmission.subdomain = "transmission.vpn";
    immich.enable = true;
    immich.subdomain = "immich.vpn";
    whisparr.enable = true;
    whisparr.subdomain = "whisparr.vpn";
    whisparr.homepage.enable = true;

    caddy = {
      baseDomain = "theless.one";

      reverseProxies =
        (mapAttrs' (
          service: _:
          nameValuePair (config.config'.caddy.genDomain config.config'.${service}.subdomain) {
            vpnOnly = true;
          }
        ) privateServices)
        // {
          "https://vpn.theless.one".vpnOnly = true;
        };
    };

    homepage = {
      enable = true;
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
    homepage-images.enable = true;

    vopono.enable = true;
    vaultwarden.enable = true;
  };
}
