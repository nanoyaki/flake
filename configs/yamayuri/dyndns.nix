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

      domains =
        map
          (subdomain: {
            domain = "hanakretzer.de";
            inherit subdomain;
          })
          [
            "*"
            ""
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
    defaults.email = "contact@nanoyaki.space";

    certs."hanakretzer.de" = {
      inherit (config.services.caddy) group;

      extraDomainNames = [ "*.hanakretzer.de" ];
      dnsProvider = "porkbun";
      dnsResolver = "173.245.58.37:53";
      dnsPropagationCheck = true;

      environmentFile = config.sops.templates."acme.env".path;
    };
  };
}
