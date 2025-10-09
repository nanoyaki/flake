{
  lib,
  pkgs,
  config,
  ...
}:

{
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
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.oink} -c ${config.sops.templates."oink.json".path} -v";
      Restart = "always";
      Type = "simple";
    };
  };

  services.caddy.globalConfig = lib.mkForce ''
    auto_https off
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
