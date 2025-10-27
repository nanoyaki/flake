{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops.secrets = {
    "porkbun/secret-api-key" = { };
    "porkbun/api-key" = { };
  };

  sops.templates."oink.json" = {
    content = builtins.toJSON {
      global = {
        secretapikey = config.sops.placeholder."porkbun/secret-api-key";
        apikey = config.sops.placeholder."porkbun/api-key";
        interval = 900;
        ttl = 600;
      };

      domains = [
        {
          domain = "hanakretzer.de";
          subdomain = "*";
        }
        {
          domain = "hanakretzer.de";
          subdomain = "";
        }
        {
          domain = "nanoyaki.space";
          subdomain = "events";
        }
      ];
    };

    restartUnits = [ "oink.service" ];
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

  sops.templates."acme.env".file = (pkgs.formats.keyValue { }).generate "acme.env" {
    PORKBUN_API_KEY = config.sops.placeholder."porkbun/api-key";
    PORKBUN_SECRET_API_KEY = config.sops.placeholder."porkbun/secret-api-key";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      inherit (config.services.caddy) group;
      email = "contact@nanoyaki.space";

      dnsProvider = "porkbun";
      dnsResolver = "173.245.58.37:53";
      dnsPropagationCheck = true;

      environmentFile = config.sops.templates."acme.env".path;
    };

    certs."hanakretzer.de".extraDomainNames = [ "*.hanakretzer.de" ];
    certs."events.nanoyaki.space" = { };
  };
}
