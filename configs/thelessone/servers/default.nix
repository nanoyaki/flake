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
      scheme = if config.services.caddy-easify.useHttps then "https://" else "http://";
    in
    "${scheme}${subdomain}${baseDomain}${slug}";

  excludes = [
    "uptimekuma"
    "immich"
    "vaultwarden"
    "jellyfin"
    "jellyseerr"
  ];

  outsideLocal = "@outside-local not client_ip private_ranges 100.64.0.0/10 10.100.0.0/24 fd7a:115c:a1e0::/48";
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
    mapAttrs'
      (
        service: _:
        nameValuePair (domain service) {
          extraConfig = ''
            ${outsideLocal}
            respond @outside-local "Access Denied" 403 {
              close
            }
          '';
          serverAliases = [ "http://${service}.vpn.nanoyaki.space" ];
        }
      )
      (
        filterAttrs (
          service: cfg: cfg.enable && !(elem service excludes)
        ) config.services.media-easify.services
      );

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
