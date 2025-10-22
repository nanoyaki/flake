{
  lib,
  pkgs,
  config,
  ...
}:

{
  # Oink for DynamicDNS
  sops.secrets = {
    "porkbun/api-key" = { };
    "porkbun/secret-api-key" = { };
  };

  sops.templates."oink.json".file = (pkgs.formats.json { }).generate "oink.json" {
    global = {
      secretapikey = config.sops.placeholder."porkbun/secret-api-key";
      apikey = config.sops.placeholder."porkbun/api-key";
      interval = 900;
      ttl = 600;
    };
    domains = lib.singleton {
      domain = "theless.one";
      subdomain = "*";
    };
  };

  systemd.services.oink = {
    description = "Dynamic DNS client for Porkbun";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.oink} -c ${config.sops.templates."oink.json".path} -v";
      Restart = "always";
      Type = "simple";
    };
  };

  # Acme for certs
  sops.templates."acme.env".file = (pkgs.formats.keyValue { }).generate "acme.env" {
    PORKBUN_API_KEY = config.sops.placeholder."porkbun/api-key";
    PORKBUN_SECRET_API_KEY = config.sops.placeholder."porkbun/secret-api-key";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@theless.one";

    certs."any.theless.one" = {
      inherit (config.services.caddy) group;

      domain = "*.theless.one";
      dnsProvider = "porkbun";
      dnsResolver = "173.245.58.37:53";
      dnsPropagationCheck = true;

      environmentFile = config.sops.templates."acme.env".path;
    };
  };

  # Load balancer / Web server
  services.caddy = {
    enable = true;
    email = "contact@theless.one";

    extraConfig = ''
      (tls) {
        tls /var/lib/acme/any.theless.one/cert.pem /var/lib/acme/any.theless.one/key.pem
      }

      (error-handling) {
        handle_errors {
          root * ${pkgs.error-pages}/share/error-pages

          @error-page file /{err.status_code}.html
          handle @error-page {
            rewrite * {file_match.relative}
            file_server
          }

          respond "{err.status_code} {err.status_text}" {err.status_code}
        }
      }
    '';

    virtualHosts = {
      "www.theless.one".extraConfig = ''
        import tls

        root * ${
          pkgs.fetchgit {
            url = "https://git.theless.one/nanoyaki/theless.one.git";
            hash = "sha256-hPeao8fJkvUdQPZcgWbmqlHkcz9ooC2z1NLeYiuLeic=";
          }
        }
        file_server

        import error-handling
      '';

      "*.theless.one".extraConfig = ''
        import tls

        reverse_proxy {
          to {http.request.host.labels.2}.server1.theless.one
          to {http.request.host.labels.2}.backup1.theless.one
          to https://down.theless.one

          lb_policy first
          lb_retries 2
          lb_try_duration 5s

          fail_duration 30s
          max_fails 2
          unhealthy_latency 2s
        }

        import error-handling
      '';

      "down.theless.one".extraConfig = ''
        import tls

        root * ${pkgs.error-pages}/share/error-pages/503.html
        file_server

        import error-handling
      '';
    };
  };
}
