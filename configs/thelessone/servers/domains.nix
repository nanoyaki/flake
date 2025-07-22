{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops.secrets = {
    "dynamicdns/vappie.space" = { };
    "porkbun/api-key" = { };
    "porkbun/secret-api-key" = { };
  };

  config'.dynamicdns.enable = true;
  config'.dynamicdns.domains."vappie.space" = {
    subdomains = [
      "*"
      "@"
    ];

    passwordFile = config.sops.secrets."dynamicdns/vappie.space".path;
  };

  sops.templates."oink.json".file = (pkgs.formats.json { }).generate "oink.json" {
    global = {
      secretapikey = config.sops.placeholder."porkbun/secret-api-key";
      apikey = config.sops.placeholder."porkbun/api-key";
      interval = 900;
      ttl = 600;
    };
    domains =
      map
        (subdomain: {
          domain = "theless.one";
          inherit subdomain;
        })
        [
          "*"
          ""
        ];
  };

  systemd.services.oink = {
    description = "Dynamic DNS client for Porkbun";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.oink} -c ${config.sops.templates."oink.json".path} -v";
      Restart = "always";
      Type = "simple";
    };
  };

  services.caddy.virtualHosts."theless.one:443" = {
    serverAliases = [
      "*.theless.one:443"
      "*.vpn.theless.one:443"
    ];
    extraConfig = ''
      tls /var/lib/acme/theless.one/cert.pem /var/lib/acme/theless.one/key.pem
    '';
  };

  sops.templates."acme.env".file = (pkgs.formats.keyValue { }).generate "acme.env" {
    PORKBUN_API_KEY = config.sops.placeholder."porkbun/api-key";
    PORKBUN_SECRET_API_KEY = config.sops.placeholder."porkbun/secret-api-key";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "hanakretzer@gmail.com";

    certs."theless.one" = {
      inherit (config.services.caddy) group;

      extraDomainNames = [
        "*.vpn.theless.one"
        "*.theless.one"
      ];
      dnsProvider = "porkbun";
      dnsResolver = "173.245.58.37:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.templates."acme.env".path;
    };
  };

  systemd.services.caddy.after = [ "acme-theless.one.service" ];
}
