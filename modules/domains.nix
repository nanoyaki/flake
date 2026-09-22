{ config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.domains ];
  };

  modules.nixos.domains =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;
    in

    {
      security.acme.certs = mkIf config.security.acme.acceptTerms {
        "hanakretzer.de" = {
          domain = "*.hanakretzer.de";
          email = "contact@nanoyaki.space";

          dnsProvider = "porkbun";
          dnsResolver = "173.245.58.37:53";
          dnsPropagationCheck = true;
        };
      };
    };
}
