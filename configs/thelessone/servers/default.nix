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
    elem
    ;

  domain =
    service:
    let
      cfg = config.services.media-easify.services.${service};

      subdomain = optionalString cfg.useSubdomain "${cfg.subdomain}.";
      slug = optionalString cfg.useDomainSlug "/${cfg.domainSlug}";
      inherit (config.services.caddy-easify) baseDomain;
    in
    "${subdomain}${baseDomain}${slug}";

  excludes = [
    "uptimekuma"
    "immich"
    "vaultwarden"
    "jellyfin"
    "jellyseerr"
  ];

  privateServices = filterAttrs (
    service: cfg: cfg.enable && !(elem service excludes)
  ) config.services.media-easify.services;
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
    ./wireguard.nix
  ];

  services.caddy-easify.baseDomain = "theless.one";

  services.caddy-easify.reverseProxies =
    (mapAttrs' (service: _: nameValuePair (domain service) { enable = false; }) privateServices)
    // (mapAttrs' (
      service: _:
      nameValuePair "http://${service}.vpn.nanoyaki.space" {
        inherit (config.services.caddy-easify.reverseProxies.${domain service}) port;
      }
    ) privateServices);

  services.media-easify.services = {
    # lidarr.enable = false;
    paperless.enable = false;
    home-assistant.enable = false;
  };

  services.homepage-easify = {
    categories = {
      Media.before = "Services";
      Services.before = "Code";
    };

    glances.layout.columns = 3;
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
        "Storage usage" = {
          metric = "fs:/";
          chart = true;
        };
      }
      {
        "Disk I/O" = {
          metric = "disk:nvme0n1";
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
          metric = "network:wg0";
          chart = true;
        };
      }
    ];
  };
}
