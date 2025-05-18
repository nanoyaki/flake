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
  ];

  services.caddy-easify.baseDomain = "theless.one";

  services.caddy-easify.reverseProxies = mapAttrs' (
    service: _:
    nameValuePair (domain service) {
      extraConfig = ''
        @outside-local not client_ip private_ranges 100.64.64.0/18 fd7a:115c:a1e0::/112
        respond @outside-local "Access Denied" 403 {
          close
        }
      '';
    }
  ) privateServices;

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
          metric = "network:tailscale0";
          chart = true;
        };
      }
    ];
  };
}
