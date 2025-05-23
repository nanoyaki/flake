{
  self,
  lib,
  config,
  ...
}:

let
  inherit (lib)
    optionalString
    nameValuePair
    mapAttrs'
    filterAttrs
    attrNames
    listToAttrs
    removeAttrs
    ;

  domain =
    service:
    let
      cfg = config.services.media-easify.services.${service};

      subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
      slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";
      inherit (config.services.caddy-easify) baseDomain;
      scheme = "http${optionalString config.services.caddy-easify.useHttps "s"}://";
    in
    "${scheme}${subdomain}${baseDomain}${slug}";

  excludes = [
    "uptimekuma"
    "immich"
    "vaultwarden"
  ];

  privateServices = filterAttrs (_: cfg: cfg.enable) (
    removeAttrs config.services.media-easify.services excludes
  );
in

{
  imports = [
    self.nixosModules.media-easify
    ./caddy.nix
    ./ssh.nix
    ./suwayomi.nix
    ./forgejo.nix
    ./minecraft
    ./woodpecker.nix
    ./dynamicdns.nix
    ./syncthing.nix
    ./steam.nix
    ./immich.nix
    ./nix-serve.nix
    ./uptime-kuma.nix
    ./dns.nix
    ./headscale.nix
    ./metrics.nix
  ];

  services.caddy-easify.baseDomain = "theless.one";

  services.caddy-easify.reverseProxies =
    (mapAttrs' (service: _: nameValuePair (domain service) { vpnOnly = true; }) privateServices)
    // {
      "https://vpn.theless.one".vpnOnly = true;
    };

  services.media-easify.arrHome = "/mnt/raid/arr-stack";

  services.media-easify.services =
    listToAttrs (
      map (service: nameValuePair service { subdomain = "${service}.vpn"; }) (
        attrNames (removeAttrs config.services.media-easify.services excludes)
      )
    )
    // {
      paperless.enable = false;
      home-assistant.enable = false;
    };

  services.homepage-easify = {
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
}
