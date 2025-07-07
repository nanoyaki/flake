{ lib, config, ... }:

let
  acmeDir = "/var/lib/acme";
in

{
  sec = {
    "porkbun/api-key" = { };
    "porkbun/secret-api-key" = { };
  };

  sops.templates."ddclient.conf".content = ''
    daemon=600
    syslog=true
    usev6=ifv6, ifv6=enp4s0
    usev4=disabled
    ssl=yes

    protocol=porkbun
    apikey=${config.sops.placeholder."porkbun/api-key"}
    secretapikey=${config.sops.placeholder."porkbun/secret-api-key"}
    root-domain=nanoyaki.space
    nanoyaki.space,events.nanoyaki.space,status.nanoyaki.space
  '';

  services.ddclient = {
    enable = true;
    configFile = config.sops.templates."ddclient.conf".path;
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

  sops.templates."acme.env".content = ''
    PORKBUN_API_KEY=${config.sops.placeholder."porkbun/api-key"}
    PORKBUN_SECRET_API_KEY=${config.sops.placeholder."porkbun/secret-api-key"}
  '';

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
