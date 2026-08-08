{
  flake.nixosModules.kanokoyuri-acme =
    {
      pkgs,
      config,
      ...
    }:

    {
      sops.secrets = {
        "porkbun/secret-api-key" = { };
        "porkbun/api-key" = { };
      };

      sops.templates."acme.env".file = pkgs.writeEnv "acme.env" {
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
      };
    };
}
