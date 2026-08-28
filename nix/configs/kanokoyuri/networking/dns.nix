{
  flake.nixosModules.kanokoyuri-dns =
    { lib, config, ... }:

    # https://github.com/carjorvaz/nixos/blob/7606b33766750c8e8d1780aa823f1144adfe7217/profiles/nixos/dns/resolved.nix
    {
      services.resolved.settings.Resolve = {
        DNS = lib.mkForce [
          "127.0.0.1"
          "::1"
        ];
        DNSOverTLS = false;
        DNSSEC = "allow-downgrade";
        LLMNR = false;
        Domains = [ "~." ];
        # systemd-resolved disables compiled-in fallback servers only when the
        # generated file contains an explicit empty FallbackDNS= assignment. An
        # empty list renders as no line, leaving the built-in fallbacks active.
        FallbackDNS = lib.mkForce [ "" ];
      };

      services.blocky = {
        enable = true;
        enableConfigCheck = true;

        settings = {
          ports.dns = 53;
          ports.tls = 853;

          upstreams = {
            init.strategy = "fast";
            strategy = "parallel_best";
            timeout = "2s";
            quic.maxIdleTimeout = "30s";
            quic.keepAlivePeriod = "15s";
            groups.default = [
              "quic:9.9.9.9:853#dns.quad9.net"
              "quic:149.112.112.112:853#dns.quad9.net"
              "quic:1.1.1.1:853#cloudflare-dns.com"
              "quic:1.0.0.1:853#cloudflare-dns.com"
              "quic:dns.adguard-dns.com:853"
            ];
          };

          blocking.denylists.ads = [
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
          ];
        };
      };

      networking.nameservers = [
        "127.0.0.1"
        "::1"
      ];

      networking.firewall.interfaces.enp1s0.allowedUDPPorts =
        with config.services.blocky.settings.ports; [
          dns
          tls
        ];
    };
}
