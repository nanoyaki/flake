{
  lib,
  pkgs,
  config,
  ...
}:

{
  sops.secrets = {
    "porkbun/nanoyaki.space/api-key" = { };
    "porkbun/nanoyaki.space/secret-api-key" = { };
    "porkbun/theless.one/api-key" = { };
    "porkbun/theless.one/secret-api-key" = { };
  };

  sops.templates."oink.nanoyaki.space.json".content = builtins.toJSON {
    global = {
      secretapikey = config.sops.placeholder."porkbun/nanoyaki.space/secret-api-key";
      apikey = config.sops.placeholder."porkbun/nanoyaki.space/api-key";
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

  sops.templates."oink.theless.one.json".content = builtins.toJSON {
    global = {
      secretapikey = config.sops.placeholder."porkbun/theless.one/secret-api-key";
      apikey = config.sops.placeholder."porkbun/theless.one/api-key";
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
          "*.backup1"
          "backup1"
        ];
  };

  systemd.services."oink-nanoyaki.space" = {
    description = "Dynamic DNS client for Porkbun";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.oink} -c ${
        config.sops.templates."oink.nanoyaki.space.json".path
      } -v";
      Restart = "always";
      Type = "simple";
    };
  };

  systemd.services."oink-theless.one" = {
    description = "Dynamic DNS client for Porkbun";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.oink} -c ${config.sops.templates."oink.theless.one.json".path} -v";
      Restart = "always";
      Type = "simple";
    };
  };

  services.caddy.globalConfig = lib.mkForce ''
    auto_https off
  '';

  sops.templates."acme.env".file = (pkgs.formats.keyValue { }).generate "acme.env" {
    PORKBUN_API_KEY = config.sops.placeholder."porkbun/nanoyaki.space/api-key";
    PORKBUN_SECRET_API_KEY = config.sops.placeholder."porkbun/nanoyaki.space/secret-api-key";
  };

  sops.templates."acme.theless.one.env".file =
    (pkgs.formats.keyValue { }).generate "acme.theless.one.env"
      {
        PORKBUN_API_KEY = config.sops.placeholder."porkbun/theless.one/api-key";
        PORKBUN_SECRET_API_KEY = config.sops.placeholder."porkbun/theless.one/secret-api-key";
      };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "contact@nanoyaki.space";
      dnsProvider = "porkbun";
      dnsPropagationCheck = true;
    };

    certs."nanoyaki.space" = {
      inherit (config.services.caddy) group;
      extraDomainNames = [ "*.nanoyaki.space" ];
      environmentFile = config.sops.templates."acme.env".path;
    };

    certs."backup1.theless.one" = {
      email = "contact@theless.one";

      inherit (config.services.caddy) group;
      extraDomainNames = [ "*.backup1.theless.one" ];
      environmentFile = config.sops.templates."acme.theless.one.env".path;
    };
  };

  systemd.services.caddy.after = [ "acme-nanoyaki.space.service" ];
}
