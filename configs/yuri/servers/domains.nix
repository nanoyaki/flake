{
  lib,
  pkgs,
  config,
  ...
}:

let
  acmeDir = "/var/lib/acme";
in

{
  sec = {
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
    domains =
      map
        (subdomain: {
          domain = "nanoyaki.space";
          inherit subdomain;
        })
        [
          "*"
          ""
        ];
  };

  systemd.services.oink = {
    description = "Dynamic DNS client for Porkbun";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.oink} -c ${config.sops.templates."oink.json".path}";
      Restart = "always";
      Type = "simple";
    };
  };

  services.caddy.globalConfig = lib.mkForce ''
    auto_https off
  '';

  services.caddy.virtualHosts."nanoyaki.space".extraConfig = ''
    handle /.well-known/acme-challenge/* {
      root * ${acmeDir}/.well-known/acme-challenge
      file_server
    }

    tls ${acmeDir}/nanoyaki.space/cert.pem ${acmeDir}/nanoyaki.space/key.pem {
      protocols tls1.3
    }
  '';

  sops.templates."acme.env".file = (pkgs.formats.keyValue { }).generate "acme.env" {
    PORKBUN_API_KEY = config.sops.placeholder."porkbun/api-key";
    PORKBUN_SECRET_API_KEY = config.sops.placeholder."porkbun/secret-api-key";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "hanakretzer@gmail.com";

    certs."nanoyaki.space" = {
      inherit (config.services.caddy) group;

      domain = "nanoyaki.space";
      extraDomainNames = [ "*.nanoyaki.space" ];
      dnsProvider = "porkbun";
      dnsPropagationCheck = true;
      environmentFile = config.sops.templates."acme.env".path;
    };
  };

  systemd.services.caddy.after = [ "acme-nanoyaki.space.service" ];
}
