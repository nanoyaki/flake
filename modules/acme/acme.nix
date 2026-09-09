{ withSystem, config, ... }:

{
  configurations.nixos.kanokoyuri = {
    imports = [ config.modules.nixos.acme ];

    security.acme.defaults.email = "contact@nanoyaki.space";
  };

  modules.nixos.acme = {
    security.acme.acceptTerms = true;
  };

  modules.nixos.sops =
    { lib, config, ... }:

    let
      inherit (lib) mkIf;

      writeEnv =
        name: attrs:
        withSystem config.nixpkgs.hostPlatform.system (
          { config, ... }: config.legacyPackages.writeEnv name attrs
        );
    in

    {
      config = mkIf config.security.acme.acceptTerms {
        sops.secrets."porkbun/secret-api-key".sopsFile = ./secrets.yaml;
        sops.secrets."porkbun/api-key".sopsFile = ./secrets.yaml;

        sops.templates."acme.env".file = writeEnv "acme.env.tpl" {
          PORKBUN_API_KEY = config.sops.placeholder."porkbun/api-key";
          PORKBUN_SECRET_API_KEY = config.sops.placeholder."porkbun/secret-api-key";
        };

        security.acme.defaults.environmentFile = config.sops.templates."acme.env".path;
      };
    };
}
